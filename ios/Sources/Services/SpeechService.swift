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

    /// BCP-47 code for both TTS voice and recognition, e.g. "en-US", "ar-SA".
    var localeIdentifier: String = "en-US"

    override init() {
        super.init()
        synth.delegate = self
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
        u.voice = AVSpeechSynthesisVoice(language: localeIdentifier)
        u.rate = AVSpeechUtteranceDefaultSpeechRate
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        synth.speak(u)
    }

    // MARK: Speech-to-text (push-to-talk)
    func startListening(onFinal: @escaping (String) -> Void) {
        guard !isListening else { return }
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let recognizer, recognizer.isAvailable else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buf, _ in
            self?.request?.append(buf)
        }
        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true

        task = recognizer.recognitionTask(with: request!) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.lastHeard = result.bestTranscription.formattedString
                if result.isFinal {
                    let text = self.lastHeard
                    self.stopListening()
                    onFinal(text)
                }
            }
            if error != nil { self.stopListening() }
        }
    }

    func stopListening() {
        guard isListening else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil; task = nil
        isListening = false
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
