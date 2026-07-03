import Foundation
import ARKit
import RealityKit
import Combine

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
    @Published var lastAssistantText = ""

    /// Current language — drives UI text, layout direction, voice, and cloud replies.
    @Published var lang: Lang = .en
    var l: L10n { L10n(lang: lang) }

    let speech = SpeechService()
    private let tracker = TawafTracker()
    private let vision = SceneVision()
    private let proxy: ProxyClient

    private weak var arView: ARView?
    private var frameCounter = 0
    private var lastObstacleSpoken = Date.distantPast
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
        view.session.delegate = self
        view.session.run(config)
    }

    func markCenter() {
        pendingCenterTap = true
        phase = .markingCenter
        statusLine = l.holdTable
    }

    func restart() {
        tracker.reset()
        circuits = 0; circuitProgress = 0
        nearestObstacle = nil
        phase = .idle
        statusLine = l.markPrompt
    }

    func askAboutScene() {
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
                tracker.setCenter(worldPosition: SIMD3(t.x, t.y, t.z))
                pendingCenterTap = false
                phase = .tawaf
                statusLine = l.beginWalking
                speech.speak(l.beginTawafSpoken)
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
                } else {
                    speech.speak(l.circuitDone(completed))
                }
            }
            circuitProgress = tracker.fractionOfCurrent
        }

        frameCounter += 1
        if frameCounter % DemoTuning.visionEveryNFrames == 0 {
            let obs = vision.observations(from: frame)
            let closest = obs.filter { ($0.distanceM ?? 99) <= DemoTuning.obstacleConsiderM }
                             .min { ($0.distanceM ?? 99) < ($1.distanceM ?? 99) }
            nearestObstacle = closest
            if let c = closest, (c.distanceM ?? 99) <= DemoTuning.obstacleWarnM,
               Date().timeIntervalSince(lastObstacleSpoken) > DemoTuning.obstacleWarnCooldown {
                lastObstacleSpoken = Date()
                speech.speak(l.personClose(c.direction), interrupting: false)
            }
        }
    }

    private func answer(question: String) async {
        guard let frame = arView?.session.currentFrame else { return }
        let obs = vision.observations(from: frame)
        let img = vision.jpegBase64(from: frame)
        let req = DescribeRequest(
            observations: obs, language: lang.rawValue,
            circuit: phase == .tawaf ? circuits : nil,
            question: question.isEmpty ? nil : question,
            imageB64: img
        )
        do {
            let resp = try await proxy.describe(req)
            lastAssistantText = resp.text
            speech.speak(resp.text)
        } catch {
            lastAssistantText = l.networkFallback
            speech.speak(l.networkFallback)
        }
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
