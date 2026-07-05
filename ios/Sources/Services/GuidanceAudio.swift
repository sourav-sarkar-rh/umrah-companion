import Foundation
import AVFoundation

/// Continuous non-visual "stay on the circle" audio for a blind pilgrim, modelled
/// on Microsoft Soundscape's beacon (see the blind-navigation research):
///
///   • A rhythmic BEACON tick, stereo-panned by `steer` — pan follows the direction
///     they should bear. On the correct heading the pan is centred.
///   • An on-axis CONFIRMATION tone layered on top when they're aimed correctly —
///     the single most important cue: sweep until it locks, then walk.
///   • A separate RADIAL-drift earcon on a distinct low timbre (centred, mono) —
///     pitch rises when drifting IN toward the Kaaba, falls when drifting OUT.
///     Silent inside the orbit band. Kept on its own channel so heading and radial
///     drift never get confused (the two-independent-errors principle).
///
/// Tones are SYNTHESISED in a render block (one `AVAudioSourceNode`) — no audio
/// files to ship. Spoken corrections are handled separately by `SpeechService`
/// (speech = discrete events, this = the continuous channel).
///
/// NOTE: audio behaviour is device-verify only (can't be judged headlessly). It's
/// OFF by default and auto-pauses while the mic is listening so speech recognition
/// gets the audio session back.
@MainActor
final class GuidanceAudio {

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var running = false

    // Live parameters read by the render block. Plain values (no locks): a stale
    // sample for one audio buffer is inaudible and can't crash.
    private var pan: Float = 0          // -1 left … +1 right
    private var beaconAmp: Float = 0    // 0 silences the tick (acquiring / paused)
    private var confAmp: Float = 0      // on-axis confirmation tone level
    private var driftAmp: Float = 0     // radial-drift earcon level
    private var driftFreq: Float = 220  // Hz, shifts with in/out drift

    // Oscillator phases (advanced in the render block).
    private var beaconGatePhase: Double = 0
    private var beaconTonePhase: Double = 0
    private var confPhase: Double = 0
    private var driftPhase: Double = 0

    // Fixed tone design (tunable on device).
    private let beaconFreq: Double = 440     // tick pitch
    private let beaconRate: Double = 3.2      // ticks per second
    private let confFreq: Double = 660        // "aimed right" lock tone
    private let sampleRate: Double = 44_100

    /// steer>0 means "bear left"; the correct-path sound should then come from the
    /// left, so pan = −steer. Flip on device if it feels inverted.
    var panFollowsSteerNegated = true

    func start() {
        guard !running else { return }
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let node = AVAudioSourceNode(format: format) { [unowned self] _, _, frameCount, audioBufferList -> OSStatus in
            self.render(frames: Int(frameCount), abl: audioBufferList)
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        source = node

        // Layer with TTS rather than fight it; duck other apps.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
        try? session.setActive(true)
        do { try engine.start(); running = true } catch { teardown() }
    }

    /// Fully stop and release the audio session (so the mic / STT can take it).
    func stop() {
        guard running else { return }
        teardown()
    }

    private func teardown() {
        engine.stop()
        if let s = source { engine.detach(s); source = nil }
        beaconAmp = 0; confAmp = 0; driftAmp = 0
        running = false
    }

    var isRunning: Bool { running }

    /// Map a guidance reading to the live tone parameters.
    func update(_ g: TawafGuide.Guidance) {
        let steer = g.steer
        pan = (panFollowsSteerNegated ? -steer : steer)

        switch g.state {
        case .acquiring:
            beaconAmp = 0.10; confAmp = 0; driftAmp = 0
        case .reversing:
            // Going the wrong way: kill the confirmation, let the hard pan + speech
            // carry it. A quiet tick still marks "the path is that way".
            beaconAmp = 0.12; confAmp = 0; driftAmp = 0
        case .onPath:
            beaconAmp = 0.16
            confAmp = g.onAxis ? 0.14 : 0
            driftAmp = 0
        case .driftingIn:
            beaconAmp = 0.16
            confAmp = g.onAxis ? 0.10 : 0
            driftAmp = 0.16; driftFreq = 300      // higher = too close to the Kaaba
        case .driftingOut:
            beaconAmp = 0.16
            confAmp = g.onAxis ? 0.10 : 0
            driftAmp = 0.16; driftFreq = 165      // lower = too far out
        }
    }

    /// Silence everything for a moment without tearing the engine down.
    func mute() { beaconAmp = 0; confAmp = 0; driftAmp = 0 }

    private func render(frames: Int, abl: UnsafeMutablePointer<AudioBufferList>) {
        let ablPtr = UnsafeMutableAudioBufferListPointer(abl)
        let left = ablPtr[0].mData!.assumingMemoryBound(to: Float.self)
        let right = ablPtr.count > 1 ? ablPtr[1].mData!.assumingMemoryBound(to: Float.self) : left

        // Equal-power pan gains.
        let theta = (max(-1, min(1, pan)) + 1) * 0.5 * (Float.pi / 2)
        let lGain = cos(theta), rGain = sin(theta)

        let beaconToneInc = beaconFreq / sampleRate
        let beaconGateInc = beaconRate / sampleRate
        let confInc = confFreq / sampleRate
        let driftInc = Double(driftFreq) / sampleRate

        for i in 0..<frames {
            // Beacon: a sine gated on for the first half of each tick period.
            let gate: Float = (beaconGatePhase.truncatingRemainder(dividingBy: 1.0) < 0.5) ? 1 : 0
            let beacon = Float(sin(2 * .pi * beaconTonePhase)) * beaconAmp * gate
            let conf = Float(sin(2 * .pi * confPhase)) * confAmp
            let drift = Float(sin(2 * .pi * driftPhase)) * driftAmp

            // Beacon pans; centred cues (confirmation + drift) go equally to both.
            let centre = (conf + drift) * 0.707
            var l = beacon * lGain + centre
            var r = beacon * rGain + centre
            l = max(-1, min(1, l)); r = max(-1, min(1, r))
            left[i] = l; right[i] = r

            beaconGatePhase += beaconGateInc
            beaconTonePhase += beaconToneInc
            confPhase += confInc
            driftPhase += driftInc
            if beaconTonePhase > 1 { beaconTonePhase -= 1 }
            if confPhase > 1 { confPhase -= 1 }
            if driftPhase > 1 { driftPhase -= 1 }
            if beaconGatePhase > 1 { beaconGatePhase -= 1 }
        }
    }
}
