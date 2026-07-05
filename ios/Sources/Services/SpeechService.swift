import Foundation
import AVFoundation
import Speech

/// On-device voice I/O — no cloud, no key.
///  • Text-to-speech via AVSpeechSynthesizer (the assistant's voice).
///  • Speech-to-text via SFSpeechRecognizer + the microphone (the pilgrim's questions).
@MainActor
final class SpeechService: NSObject, ObservableObject {
    @Published var isSpeaking = false
    @Published var isListening = false
    @Published var lastHeard: String = ""

    private let synth = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var onFinal: ((String) -> Void)?

    /// BCP-47 code for both TTS voice and recognition, e.g. "en-US", "ar-SA".
    var localeIdentifier: String = "en-US"

    override init() {
        super.init()
        synth.delegate = self
        // Claim a TTS-friendly category up front. RealityKit's ARView also grabs the
        // shared audio session (for spatial audio) once the AR view mounts, so we
        // re-assert this right before every utterance in `speak(_:)` as well.
        try? AVAudioSession.sharedInstance()
            .setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }

    func requestPermissions() async {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { _ in cont.resume() }
        }
        await AVAudioApplication.requestRecordPermission()
    }

    // MARK: Text-to-speech
    func speak(_ text: String, interrupting: Bool = true) {
        guard !text.isEmpty else { return }
        if interrupting, synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let u = AVSpeechUtterance(string: text)
        // Fall back to any voice for the language, then the system default, so a
        // missing/edge locale never yields a silent utterance.
        u.voice = AVSpeechSynthesisVoice(language: localeIdentifier)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        u.rate = AVSpeechUtteranceDefaultSpeechRate
        // Re-assert over whatever ARView/RealityKit left the session as.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        synth.speak(u)
    }

    // MARK: Speech-to-text (tap to start, tap again to stop)
    func startListening(onFinal: @escaping (String) -> Void) {
        guard !isListening else { return }
        self.onFinal = onFinal
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let recognizer, recognizer.isAvailable else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch { return }

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buf, _ in
            self?.request?.append(buf)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            // Mic failed to start — tear down instead of getting stuck on "Listening…".
            node.removeTap(onBus: 0)
            request = nil
            restorePlaybackSession()
            return
        }
        isListening = true

        task = recognizer.recognitionTask(with: request!) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result { self.lastHeard = result.bestTranscription.formattedString }
                if result?.isFinal == true || error != nil { self.finishListening() }
            }
        }

        // Safety: never listen forever. Auto-finish after 8s if the user doesn't tap to stop.
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self, self.isListening else { return }
            self.finishListening()
        }
    }

    /// Stop listening and hand back whatever was heard so far (used by the tap-to-stop
    /// button, the silence detector, and the safety timeout).
    func finishListening() {
        guard isListening else { return }
        let text = lastHeard
        stopListening()
        let handler = onFinal
        onFinal = nil
        handler?(text)
    }

    func stopListening() {
        guard isListening else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil; task = nil
        isListening = false
        restorePlaybackSession()   // give the session back to TTS
    }

    /// Return the shared audio session to a state where the assistant's voice plays.
    private func restorePlaybackSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didStart u: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = true }
    }
    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
