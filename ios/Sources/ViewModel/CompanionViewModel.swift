import Foundation
import ARKit
import RealityKit
import Combine
import UIKit

/// The demo's brain. Owns the ARSession, feeds each frame to the Tawaf tracker
/// and the on-device vision, drives spoken guidance, and calls the cloud proxy
/// on demand. Everything the UI shows is @Published here. Fully multi-language:
/// UI text, voice, and cloud replies all follow `lang`.
@MainActor
final class CompanionViewModel: NSObject, ObservableObject, ARSessionDelegate {

    enum Phase { case idle, markingCenter, tawaf, complete }

    @Published var phase: Phase = .idle
    @Published var circuits = 0
    @Published var circuitProgress: Float = 0
    @Published var trackingOK = false
    @Published var statusLine = ""
    @Published var nearestObstacle: Observation?
    /// The few nearest detected objects, for the on-screen "what I see" readout.
    @Published var detections: [Observation] = []
    @Published var lastAssistantText = ""
    /// "Terminator" debug overlay — shows the live LiDAR mesh + feature points.
    @Published var debugMesh = false
    /// When true, the automatic obstacle warnings stay silent (the on-screen
    /// readout still shows). Ritual announcements + on-demand answers still speak.
    @Published var warningsMuted = false

    /// Current language — drives UI text, layout direction, voice, and cloud replies.
    @Published var lang: Lang = .en
    var l: L10n { L10n(lang: lang) }

    /// Walk-guidance for a blind pilgrim (off by default — see `guidanceOn`).
    @Published var guidanceOn = false
    @Published var guidanceState: TawafGuide.State = .acquiring
    @Published var guidanceSteerLeft = true

    let speech = SpeechService()
    private let tracker = TawafTracker()
    private let guide = TawafGuide()
    let guidanceAudio = GuidanceAudio()
    private let vision = SceneVision()
    private let proxy: ProxyClient

    private weak var arView: ARView?
    private var kaabaAnchor: AnchorEntity?
    private var frameCounter = 0
    private var lastObstacleSpoken = Date.distantPast
    private var lastGuidanceState: TawafGuide.State?
    private var lastGuidanceCue = Date.distantPast
    private var pendingCenterTap = false

    init(proxyBaseURL: URL) {
        self.proxy = ProxyClient(baseURL: proxyBaseURL)
        super.init()
        statusLine = l.markPrompt
    }

    func onAppear() {
        Task { await speech.requestPermissions() }
    }

    func setLanguage(_ newLang: Lang) {
        lang = newLang
        speech.localeIdentifier = newLang.bcp47
        refreshStatus()
    }

    // MARK: AR lifecycle
    func attach(to view: ARView) {
        arView = view
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)   // LiDAR
        }
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh          // LiDAR room mesh (for debug view + occlusion)
        }
        view.session.delegate = self
        view.session.run(config)
    }

    /// Toggle the "Terminator" debug overlay: the reconstructed LiDAR mesh plus
    /// feature points and the world origin, for showing how the phone sees the room.
    func toggleDebug() {
        debugMesh.toggle()
        arView?.debugOptions = debugMesh
            ? [.showSceneUnderstanding, .showFeaturePoints, .showWorldOrigin]
            : []
    }

    /// Drop a virtual Kaaba (black cube + gold kiswa band) at the marked center,
    /// resting on the surface the raycast hit. Purely cosmetic.
    private func placeKaaba(at world: SIMD3<Float>) {
        guard let arView else { return }
        kaabaAnchor.map { arView.scene.removeAnchor($0) }

        let side = DemoTuning.kaabaSizeM
        let anchor = AnchorEntity(world: world)

        let cube = ModelEntity(
            mesh: .generateBox(size: side, cornerRadius: side * 0.01),
            materials: [SimpleMaterial(color: UIColor(white: 0.03, alpha: 1), isMetallic: false)])
        cube.position.y = side / 2   // rest on the plane the raycast hit

        // Gold kiswa band around the upper third.
        let band = ModelEntity(
            mesh: .generateBox(width: side * 1.03, height: side * 0.14, depth: side * 1.03),
            materials: [SimpleMaterial(color: UIColor(red: 0.83, green: 0.68, blue: 0.33, alpha: 1),
                                       isMetallic: true)])
        band.position.y = side * 0.72
        cube.addChild(band)

        anchor.addChild(cube)
        arView.scene.addAnchor(anchor)
        kaabaAnchor = anchor
    }

    func markCenter() {
        pendingCenterTap = true
        phase = .markingCenter
        statusLine = l.holdTable
    }

    func restart() {
        tracker.reset()
        guide.reset()
        guidanceAudio.stop()
        lastGuidanceState = nil
        guidanceState = .acquiring
        circuits = 0; circuitProgress = 0
        nearestObstacle = nil
        detections = []
        kaabaAnchor.map { arView?.scene.removeAnchor($0) }
        kaabaAnchor = nil
        phase = .idle
        statusLine = l.markPrompt
    }

    /// Turn walk-guidance on/off. Starts/stops the continuous beacon; only audible
    /// while actually walking (phase == .tawaf).
    func toggleGuidance() {
        guidanceOn.toggle()
        if guidanceOn, phase == .tawaf { guidanceAudio.start() }
        else { guidanceAudio.stop() }
    }

    /// Speak a terse, egocentric correction on state change or after a cooldown.
    /// Continuous nuance lives in the beacon; speech is for discrete events only.
    private func speakGuidance(_ g: TawafGuide.Guidance) {
        let now = Date()
        let changed = g.state != lastGuidanceState
        let prev = lastGuidanceState
        defer { lastGuidanceState = g.state }
        guard g.state != .acquiring else { return }
        let minGap: TimeInterval = 3
        let due = changed || now.timeIntervalSince(lastGuidanceCue) > minGap
        switch g.state {
        case .reversing where due:
            lastGuidanceCue = now; speech.speak(l.reversingSpoken, interrupting: false)
        case .driftingIn where due:
            lastGuidanceCue = now; speech.speak(l.driftInSpoken, interrupting: false)
        case .driftingOut where due:
            lastGuidanceCue = now; speech.speak(l.driftOutSpoken, interrupting: false)
        case .onPath:
            if changed, let p = prev, p != .acquiring {
                speech.speak(l.backOnPathSpoken, interrupting: false)
            } else if !g.onAxis, abs(g.steer) > 0.5, due {
                lastGuidanceCue = now
                speech.speak(l.bearCue(left: g.steer > 0), interrupting: false)
            }
        default: break
        }
    }

    func askAboutScene() {
        // Tap while already listening = stop and send what was heard.
        if speech.isListening { speech.finishListening(); return }
        guidanceAudio.stop()          // free the audio session for the mic
        speech.startListening { [weak self] heard in
            guard let self else { return }
            Task { await self.answer(question: heard) }
        }
    }

    // MARK: ARSessionDelegate
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in self.handle(frame: frame) }
    }

    nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        Task { @MainActor in
            if case .normal = camera.trackingState { self.trackingOK = true }
            else { self.trackingOK = false }
        }
    }

    private func handle(frame: ARFrame) {
        if pendingCenterTap, let view = arView {
            let mid = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            if let q = view.raycast(from: mid, allowing: .estimatedPlane, alignment: .any).first {
                let t = q.worldTransform.columns.3
                let center = SIMD3<Float>(t.x, t.y, t.z)
                tracker.setCenter(worldPosition: center)
                guide.setCenter(SIMD2(center.x, center.z))
                lastGuidanceState = nil
                placeKaaba(at: center)
                pendingCenterTap = false
                phase = .tawaf
                statusLine = l.beginWalking
                speech.speak(l.beginTawafSpoken)
                if guidanceOn { guidanceAudio.start() }
            }
        }

        if phase == .tawaf {
            let cam = frame.camera.transform.columns.3
            if let completed = tracker.update(cameraWorldPosition: SIMD3(cam.x, cam.y, cam.z)) {
                circuits = completed
                if tracker.isComplete {
                    phase = .complete
                    statusLine = l.tawafComplete
                    speech.speak(l.tawafFinishedSpoken)
                    guidanceAudio.stop()
                } else {
                    speech.speak(l.circuitDone(completed))
                }
            }
            circuitProgress = tracker.fractionOfCurrent

            // Circle-guidance: where the pilgrim is aimed + orbit drift.
            if guidanceOn {
                let m = frame.camera.transform
                let camPos = SIMD2<Float>(cam.x, cam.z)
                let fwd = SIMD2<Float>(-m.columns.2.x, -m.columns.2.z)   // camera forward, on the floor
                if let gd = guide.update(position: camPos, forward: fwd) {
                    guidanceAudio.update(gd)
                    guidanceState = gd.state
                    guidanceSteerLeft = gd.steer > 0     // steer>0 ⇒ bear left (guide default)
                    if !speech.isListening { speakGuidance(gd) }
                }
            }
        }

        frameCounter += 1
        if frameCounter % DemoTuning.visionEveryNFrames == 0 {
            let ranked = vision.observations(from: frame)
                .sorted { ($0.distanceM ?? 99) < ($1.distanceM ?? 99) }
            detections = Array(ranked.prefix(4))

            let closest = ranked.first { ($0.distanceM ?? 99) <= DemoTuning.obstacleConsiderM }
            nearestObstacle = closest
            if let c = closest, let d = c.distanceM, d <= DemoTuning.obstacleWarnM,
               Date().timeIntervalSince(lastObstacleSpoken) > DemoTuning.obstacleWarnCooldown,
               !speech.isListening, !warningsMuted {
                lastObstacleSpoken = Date()
                speech.speak(l.obstacleNear(c.label, c.direction, d), interrupting: false)
            }
        }
    }

    /// Answer "what's around me?" ENTIRELY ON-DEVICE — no server, no key, works
    /// offline. We already have precise object + LiDAR-distance + direction data
    /// from `SceneVision`, so we synthesize the spoken description locally.
    /// (The cloud proxy path still exists in `ProxyClient` for richer open-ended
    /// answers if we ever want to run it, but it's no longer required.)
    private func answer(question: String) async {
        guard let frame = arView?.session.currentFrame else { return }
        let obs = vision.observations(from: frame)
            .sorted { ($0.distanceM ?? 99) < ($1.distanceM ?? 99) }
        let text = l.sceneDescription(Array(obs.prefix(4)))
        lastAssistantText = text
        speech.speak(text)
        if guidanceOn, phase == .tawaf { guidanceAudio.start() }   // resume the beacon
    }

    private func refreshStatus() {
        switch phase {
        case .idle: statusLine = l.markPrompt
        case .markingCenter: statusLine = l.holdTable
        case .tawaf: statusLine = l.beginWalking
        case .complete: statusLine = l.tawafComplete
        }
    }
}
