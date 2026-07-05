import Foundation

/// One place for every hand-tunable number in the demo, so F8 on-device tuning
/// is a single file to touch — nothing buried in the frame loop.
///
/// NOTE ON RADIUS: circuit counting has NO distance/radius parameter by design —
/// `TawafTracker` is purely angular and works at any loop size (small table or
/// wide Mataf). The knobs below are only the on-device OBSTACLE-warning
/// thresholds, which are independent of how wide you walk.
enum DemoTuning {
    /// How often (in frames) to run the on-device people/obstacle pass. ARKit runs
    /// ~60fps; every 30 frames ≈ twice a second, enough for walking pace.
    static let visionEveryNFrames = 30

    /// Only surface people closer than this (m) as obstacles worth showing.
    static let obstacleConsiderM: Double = 2.0

    /// Speak a spoken warning when someone is at or under this distance (m).
    static let obstacleWarnM: Double = 1.3

    /// Minimum gap (s) between spoken obstacle warnings, so it doesn't nag.
    static let obstacleWarnCooldown: TimeInterval = 4

    /// Edge length (m) of the virtual Kaaba cube dropped at the marked center.
    /// ~0.4 m reads well on a table; bump up for a room-scale walk. Purely
    /// cosmetic — it does NOT affect circuit counting (that's angular).
    static let kaabaSizeM: Float = 0.4

    /// Demo toggle: the open-ended "what's around me?" scene answer (the AI/cloud
    /// reasoning path). Voice COMMANDS (tawaf, mark, reset, guide, dua…) stay live
    /// regardless — this only gates the free-form scene description, which is the
    /// least reliable thing to show live. Flip back to `true` to restore it.
    static let sceneAnswerEnabled = false

    /// Sa'i walk-guidance thresholds. Scale-free like the tracker: the off-path
    /// tolerance is a fraction of the marked Safa↔Marwah distance (with a floor),
    /// so it works at table scale or full Mas'a scale.
    static let saiOffPathFraction: Float = 0.15
    static let saiOffPathFloorM: Float = 0.3
    /// Smoothed progress-toward-target velocity below this (negative) = walking the
    /// wrong way. Progress is the 0→1 fraction toward the endpoint being walked to.
    static let saiReverseThreshold: Float = 0.0015
}
