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
}
