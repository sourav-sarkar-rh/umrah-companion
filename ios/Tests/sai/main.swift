// Headless simulation harness for SaiTracker — the "Playwright" for Sa'i logic.
// Compiles the REAL tracker (no mocks) and drives it with a synthetic pilgrim
// pacing back and forth between two endpoints, then asserts length counts.
// Runs on macOS with no Xcode:
//   swiftc Sources/AR/SaiTracker.swift Tests/sai_main.swift -o /tmp/saisim && /tmp/saisim
import Foundation
import simd

var failures = 0
func expect(_ cond: Bool, _ msg: String) {
    print((cond ? "  ok   " : "  FAIL ") + msg)
    if !cond { failures += 1 }
}

/// Walk `lengths` one-way traversals between safa and marwah, `steps` samples per
/// traversal. Starts at Safa. Returns (finalLengths, everyReportedCompletion, endedAt).
func pace(_ t: SaiTracker, safa a: SIMD3<Float>, marwah b: SIMD3<Float>,
          lengths: Int, steps: Int) -> (Int, [Int], SaiTracker.End?) {
    t.setEndpoints(safa: a, marwah: b)
    var reported: [Int] = []
    // seed the starting end
    t.update(cameraWorldPosition: a)
    for leg in 0..<lengths {
        let goingToMarwah = (leg % 2 == 0)   // leg 0: Safa->Marwah, leg 1: Marwah->Safa, ...
        let from = goingToMarwah ? a : b
        let to   = goingToMarwah ? b : a
        for i in 1...steps {
            let f = Float(i) / Float(steps)
            let p = from + (to - from) * f
            if let done = t.update(cameraWorldPosition: p) { reported.append(done) }
        }
    }
    return (t.lengths, reported, t.lastArrived)
}

print("SaiTracker simulation")

let safa = SIMD3<Float>(0, 0, 0)
let marwah = SIMD3<Float>(3, 0, 0)      // 3m apart — living-room scale

// 1) Seven lengths starting at Safa -> exactly 7, reported 1..7, ending at Marwah.
let (n7, rep7, end7) = pace(SaiTracker(), safa: safa, marwah: marwah, lengths: 7, steps: 120)
expect(n7 == 7, "7 traversals count 7 lengths (got \(n7))")
expect(rep7 == [1,2,3,4,5,6,7], "reports each length once, in order (got \(rep7))")
expect(end7 == .marwah, "7th length ends at Marwah (got \(String(describing: end7)))")

// 2) Does not over-count past 7 even if the pilgrim keeps pacing.
let (n9, _, _) = pace(SaiTracker(), safa: safa, marwah: marwah, lengths: 9, steps: 120)
expect(n9 == 7, "caps at 7 lengths even after extra traversals (got \(n9))")

// 3) A single one-way trip -> exactly 1 length.
let (n1, rep1, _) = pace(SaiTracker(), safa: safa, marwah: marwah, lengths: 1, steps: 120)
expect(n1 == 1 && rep1 == [1], "one traversal completes exactly one length (got \(n1), \(rep1))")

// 4) Loitering / jitter near Safa should not register a length.
let jt = SaiTracker(); jt.setEndpoints(safa: safa, marwah: marwah)
jt.update(cameraWorldPosition: safa)
for i in 0..<500 {
    let n = Float(i % 5) * 0.02          // tiny wobble near Safa, never reaching Marwah
    jt.update(cameraWorldPosition: SIMD3(n, 0, 0))
}
expect(jt.lengths == 0, "wobbling at Safa counts nothing (got \(jt.lengths))")

// 5) Same logic at full Mas'a scale (~450m corridor) counts 7.
let (nBig, _, _) = pace(SaiTracker(), safa: SIMD3(10,0,10), marwah: SIMD3(10,0,460),
                        lengths: 7, steps: 300)
expect(nBig == 7, "same logic at 450m corridor counts 7 (got \(nBig))")

// 6) A short overshoot past 90% but turning back before the end should still
//    count once you actually arrive (hysteresis sanity: partial legs don't count).
let pt = SaiTracker(); pt.setEndpoints(safa: safa, marwah: marwah); pt.update(cameraWorldPosition: safa)
for i in 1...60 { let f = Float(i)/60 * 0.8; pt.update(cameraWorldPosition: safa + (marwah-safa)*f) }
expect(pt.lengths == 0, "reaching only 80% toward Marwah counts no length (got \(pt.lengths))")

print(failures == 0 ? "\nALL PASS" : "\n\(failures) FAILURE(S)")
exit(failures == 0 ? 0 : 1)
