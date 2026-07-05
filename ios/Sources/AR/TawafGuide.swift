import Foundation
import simd

/// The Tawaf *guidance* brain — the piece that lets a BLIND pilgrim walk a proper
/// circuit without sight. `TawafTracker` only *counts* angular sweeps (it happily
/// counts a spiral drifting into the Kaaba); this decides whether the pilgrim is
/// actually on a good orbit and, if not, which way to correct.
///
/// It is intentionally pure (Foundation + simd only) so it runs under the headless
/// "Playwright" sim with no device — feed it positions + headings, assert the state.
///
/// Coordinate convention matches `TawafTracker`: we work in the horizontal (x, z)
/// plane, stored as `SIMD2(x, z)`. `angle = atan2(z, x)`; real (counter-clockwise)
/// Tawaf DECREASES that angle, so counter-clockwise angular velocity is NEGATIVE.
///
/// Two error dimensions are reported independently so the audio layer can sonify
/// them on separate channels (per the blind-navigation research — heading and
/// radial drift must not be conflated):
///   • `steer` / `onAxis` — is the pilgrim FACING along the counter-clockwise
///     tangent (which way to walk), and how far off.
///   • `radiusError` / state — is the pilgrim holding the orbit, or drifting in
///     toward the Kaaba / out into the crowd.
final class TawafGuide {

    enum State: Equatable {
        case acquiring     // still learning the target orbit radius, or standing at the center
        case onPath        // good: on the orbit, moving counter-clockwise
        case driftingIn    // too close to the center (toward the Kaaba)
        case driftingOut   // too far from the center (out into the crowd / walls)
        case reversing     // moving clockwise — the wrong way
    }

    struct Guidance: Equatable {
        var state: State
        /// Rotation the pilgrim needs to make to face along the CCW tangent, mapped
        /// to [-1, 1] (0 = aimed correctly). Sign → spoken "bear left / bear right"
        /// via `steerIsLeftWhenPositive` (confirm the sign on device, like the CCW
        /// convention in TawafTracker).
        var steer: Float
        /// True when heading is within `onAxisToleranceRad` of the CCW tangent —
        /// this drives the Soundscape-style "you're aimed right" confirmation tone.
        var onAxis: Bool
        /// Signed metres off the target orbit: + = too far out, − = too close in.
        var radiusError: Float
        /// Current distance from the marked center (metres).
        var radius: Float
    }

    // MARK: Marked center + learned orbit
    private(set) var center: SIMD2<Float>?
    /// The orbit radius we lock onto from the pilgrim's first steps (no hard-coded
    /// distance — works at table scale or full Mataf scale, like the tracker).
    private(set) var targetRadius: Float?

    // MARK: Tunables (F8 — set on device)
    /// Ignore jitter closer than this to the center (matches TawafTracker).
    var minRadius: Float = 0.15
    /// Acceptable orbit band = ±max(this metres, fraction·target).
    var radialToleranceFraction: Float = 0.30
    var minRadialToleranceM: Float = 0.12
    /// Heading within this many radians of the tangent counts as "on axis" (~15°).
    var onAxisToleranceRad: Float = 0.26
    /// Smoothed clockwise angular velocity above this (rad/update) = reversing.
    var reverseAngleThreshold: Float = 0.012
    /// How many moving samples to average before locking the target radius.
    var acquireSamples: Int = 30
    /// Sign mapping for spoken guidance: does steer>0 mean "bear left"?
    var steerIsLeftWhenPositive = true

    // MARK: State
    private var acquireAccum: Float = 0
    private var acquireCount: Int = 0
    private var lastAngle: Float?
    private var angVelSmoothed: Float = 0

    var isAcquired: Bool { targetRadius != nil }

    func setCenter(_ c: SIMD2<Float>) {
        center = c
        resetLearning()
    }

    func reset() {
        center = nil
        resetLearning()
    }

    private func resetLearning() {
        targetRadius = nil
        acquireAccum = 0
        acquireCount = 0
        lastAngle = nil
        angVelSmoothed = 0
    }

    /// Feed the pilgrim's current horizontal position and facing (both in world
    /// (x, z)). `forward` need not be normalised. Returns nil only before a center
    /// is marked.
    func update(position p: SIMD2<Float>, forward f: SIMD2<Float>) -> Guidance? {
        guard let c = center else { return nil }

        let v = p - c
        let radius = simd_length(v)

        // Standing on/near the center — can't define a tangent yet.
        guard radius > minRadius else {
            return Guidance(state: .acquiring, steer: 0, onAxis: false,
                            radiusError: 0, radius: radius)
        }

        let rhat = v / radius
        // Counter-clockwise tangent: rotate the radial unit vector −90° in (x, z).
        let tangent = SIMD2<Float>(rhat.y, -rhat.x)

        // Heading error → signed rotation from `forward` to the CCW tangent.
        let fLen = simd_length(f)
        let fn = fLen > 1e-4 ? f / fLen : tangent
        let dot = simd_dot(fn, tangent)
        let cross = fn.x * tangent.y - fn.y * tangent.x     // 2-D scalar cross
        let steerAngle = atan2(cross, dot)
        var steer = simd_clamp(steerAngle / (.pi / 2), -1, 1)
        if !steerIsLeftWhenPositive { steer = -steer }
        let onAxis = abs(steerAngle) <= onAxisToleranceRad

        // Angular velocity (for reverse detection), unwrapped, EMA-smoothed.
        let angle = atan2(v.y, v.x)
        if let last = lastAngle {
            var d = angle - last
            if d > .pi { d -= 2 * .pi }
            if d < -.pi { d += 2 * .pi }
            angVelSmoothed = angVelSmoothed * 0.8 + d * 0.2
        }
        lastAngle = angle

        // Learn the target orbit from the first moving samples.
        guard let target = targetRadius else {
            acquireAccum += radius
            acquireCount += 1
            if acquireCount >= acquireSamples { targetRadius = acquireAccum / Float(acquireCount) }
            return Guidance(state: .acquiring, steer: steer, onAxis: onAxis,
                            radiusError: 0, radius: radius)
        }

        let band = max(minRadialToleranceM, target * radialToleranceFraction)
        let radiusError = radius - target

        // Priority: going the wrong way is the most urgent thing to fix.
        let state: State
        if angVelSmoothed > reverseAngleThreshold {       // positive = clockwise = wrong way
            state = .reversing
        } else if radiusError > band {
            state = .driftingOut
        } else if radiusError < -band {
            state = .driftingIn
        } else {
            state = .onPath
        }

        return Guidance(state: state, steer: steer, onAxis: onAxis,
                        radiusError: radiusError, radius: radius)
    }
}
