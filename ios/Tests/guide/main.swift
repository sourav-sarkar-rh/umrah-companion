// Headless simulation for TawafGuide — drives the REAL guide (no mocks) with a
// synthetic pilgrim and asserts the guidance state. Runs on macOS, no Xcode:
//   cd ios && swiftc Sources/AR/TawafGuide.swift Tests/guide/main.swift -o /tmp/guidesim && /tmp/guidesim
import Foundation
import simd

var failures = 0
func expect(_ cond: Bool, _ msg: String) {
    print((cond ? "  ok   " : "  FAIL ") + msg)
    if !cond { failures += 1 }
}

let center = SIMD2<Float>(0, 0)

/// Position on a circle of radius `r` at CCW-parameter step `i` of `steps` per loop.
/// dir = -1 → counter-clockwise (real Tawaf, angle decreasing); +1 → clockwise.
func pos(_ r: Float, _ i: Int, _ steps: Int, _ dir: Float) -> SIMD2<Float> {
    let theta = dir * (2 * .pi) * Float(i) / Float(steps)
    return SIMD2(r * cos(theta), r * sin(theta))
}

/// The CCW tangent (correct facing) at parameter step `i`.
func ccwTangent(_ i: Int, _ steps: Int, _ dir: Float) -> SIMD2<Float> {
    let theta = dir * (2 * .pi) * Float(i) / Float(steps)
    return SIMD2(sin(theta), -cos(theta))
}

// Collect the state distribution over a run, skipping the acquisition phase.
func run(radiusAt: (Int) -> Float, dir: Float, forward: (Int) -> SIMD2<Float>,
         steps: Int, loops: Double) -> (counts: [TawafGuide.State: Int], lastSteerMag: Float, lastOnAxis: Bool) {
    let g = TawafGuide()
    g.setCenter(center)
    var counts: [TawafGuide.State: Int] = [:]
    var lastSteer: Float = 0
    var lastOnAxis = false
    let total = Int(Double(steps) * loops)
    for i in 0...total {
        let p = pos(radiusAt(i), i, steps, dir)
        guard let gd = g.update(position: p, forward: forward(i)) else { continue }
        if g.isAcquired && gd.state != .acquiring {
            counts[gd.state, default: 0] += 1
            lastSteer = gd.steer
            lastOnAxis = gd.onAxis
        }
    }
    return (counts, abs(lastSteer), lastOnAxis)
}

print("TawafGuide simulation")

// 1) Good CCW pilgrim, constant radius, facing along the tangent →
//    overwhelmingly onPath, on-axis, never reversing.
let good = run(radiusAt: { _ in 0.7 }, dir: -1,
               forward: { ccwTangent($0, 240, -1) }, steps: 240, loops: 3)
let onPath = good.counts[.onPath, default: 0]
let totalGood = good.counts.values.reduce(0, +)
expect(good.counts[.reversing, default: 0] == 0, "good CCW walk never flags reversing")
expect(Double(onPath) / Double(max(1, totalGood)) > 0.9, "good CCW walk is >90% onPath (got \(onPath)/\(totalGood))")
expect(good.lastOnAxis && good.lastSteerMag < 0.05, "facing the tangent reads on-axis, steer≈0 (steer=\(good.lastSteerMag))")

// 2) Outward spiral after a clean warm-up loop → driftingOut appears, never driftingIn.
let out = run(radiusAt: { i in 0.7 + max(0, Float(i - 240)) * 0.002 }, dir: -1,
              forward: { ccwTangent($0, 240, -1) }, steps: 240, loops: 3)
expect(out.counts[.driftingOut, default: 0] > 0, "growing radius is flagged driftingOut")
expect(out.counts[.driftingIn, default: 0] == 0, "outward spiral is never flagged driftingIn")

// 3) Inward spiral (toward the Kaaba) → driftingIn appears.
let inn = run(radiusAt: { i in max(0.2, 0.9 - max(0, Float(i - 240)) * 0.002) }, dir: -1,
              forward: { ccwTangent($0, 240, -1) }, steps: 240, loops: 3)
expect(inn.counts[.driftingIn, default: 0] > 0, "shrinking radius is flagged driftingIn")

// 4) Clockwise pilgrim (wrong way) → reversing dominates once velocity settles.
let rev = run(radiusAt: { _ in 0.7 }, dir: +1,
              forward: { ccwTangent($0, 240, +1) }, steps: 240, loops: 3)
expect(rev.counts[.reversing, default: 0] > rev.counts[.onPath, default: 0],
       "clockwise walk is mostly flagged reversing (rev=\(rev.counts[.reversing, default: 0]), onPath=\(rev.counts[.onPath, default: 0]))")

// 5) Facing the WRONG way (backwards) on a good orbit → large steer, off-axis.
let g5 = TawafGuide(); g5.setCenter(center)
var big = false
for i in 0...300 {
    let p = pos(0.7, i, 240, -1)
    let backwards = -ccwTangent(i, 240, -1)      // facing clockwise tangent
    if let gd = g5.update(position: p, forward: backwards), g5.isAcquired {
        if abs(gd.steer) > 0.8 && !gd.onAxis { big = true }
    }
}
expect(big, "facing backwards yields large steer + off-axis")

// 6) Target radius is LEARNED, not hard-coded: same code locks a ~5 m orbit.
let g6 = TawafGuide(); g6.setCenter(SIMD2(3, 3))
for i in 0...120 {
    let theta = -(2 * .pi) * Float(i) / Float(240)
    _ = g6.update(position: SIMD2(3 + 5 * cos(theta), 3 + 5 * sin(theta)),
                  forward: ccwTangent(i, 240, -1))
}
expect((g6.targetRadius ?? 0) > 4.5 && (g6.targetRadius ?? 0) < 5.5,
       "locks the orbit radius from the walk itself (got \(g6.targetRadius ?? -1))")

print(failures == 0 ? "\nALL PASS" : "\n\(failures) FAILURE(S)")
exit(failures == 0 ? 0 : 1)
