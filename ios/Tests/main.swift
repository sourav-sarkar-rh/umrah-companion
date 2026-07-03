// Headless simulation harness for TawafTracker — the "Playwright" for our ritual logic.
// Compiles the REAL tracker (no mocks) and drives it with a synthetic pilgrim walking
// loops around a center, then asserts circuit counts. Runs on macOS with no Xcode:
//   swiftc Sources/AR/TawafTracker.swift Tests/main.swift -o /tmp/tawafsim && /tmp/tawafsim
import Foundation
import simd

var failures = 0
func expect(_ cond: Bool, _ msg: String) {
    print((cond ? "  ok   " : "  FAIL ") + msg)
    if !cond { failures += 1 }
}

/// Walk `loops` full circles of radius `r` around `center`, `steps` samples per loop.
/// direction: -1 = counter-clockwise (real Tawaf), +1 = clockwise.
/// Returns (finalCircuits, everyReportedCompletion).
func walk(_ t: TawafTracker, center: SIMD3<Float>, r: Float,
          loops: Double, steps: Int, direction: Float) -> (Int, [Int]) {
    t.setCenter(worldPosition: center)
    var reported: [Int] = []
    let total = Int(Double(steps) * loops)
    for i in 0...total {
        let theta = direction * (2 * .pi) * Float(i) / Float(steps)
        let p = SIMD3<Float>(center.x + r * cos(theta),
                             center.y,
                             center.z + r * sin(theta))
        if let done = t.update(cameraWorldPosition: p) { reported.append(done) }
    }
    return (t.circuits, reported)
}

print("TawafTracker simulation")

// 1) Seven counter-clockwise loops -> exactly 7 circuits, reported 1..7 in order.
let (c7, rep7) = walk(TawafTracker(), center: SIMD3(0,0,0), r: 0.7, loops: 7, steps: 240, direction: -1)
expect(c7 == 7, "7 CCW loops around a 0.7m table counts 7 circuits (got \(c7))")
expect(rep7 == [1,2,3,4,5,6,7], "reports each circuit once, in order (got \(rep7))")

// 2) Does not over-count past 7 even if the pilgrim keeps moving.
let (c9, _) = walk(TawafTracker(), center: SIMD3(0,0,0), r: 0.7, loops: 9, steps: 240, direction: -1)
expect(c9 == 7, "caps at 7 circuits even after extra loops (got \(c9))")

// 3) Half a loop -> zero completed circuits.
let (cHalf, _) = walk(TawafTracker(), center: SIMD3(0,0,0), r: 0.7, loops: 0.5, steps: 240, direction: -1)
expect(cHalf == 0, "half a loop completes no circuit (got \(cHalf))")

// 4) Works at a large (Mataf-scale) radius too.
let (cBig, _) = walk(TawafTracker(), center: SIMD3(5,0,5), r: 8.0, loops: 7, steps: 400, direction: -1)
expect(cBig == 7, "same logic at 8m radius counts 7 (got \(cBig))")

// 5) Jitter standing near the center should not register circuits.
let jt = TawafTracker(); jt.setCenter(worldPosition: SIMD3(0,0,0))
for i in 0..<500 {
    let n = Float(i % 7) * 0.01
    jt.update(cameraWorldPosition: SIMD3(n, 0, -n))
}
expect(jt.circuits == 0, "standing/jittering at the center counts nothing (got \(jt.circuits))")

print(failures == 0 ? "\nALL PASS" : "\n\(failures) FAILURE(S)")
exit(failures == 0 ? 0 : 1)
