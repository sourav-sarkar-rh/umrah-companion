import Foundation
import simd

/// Counts Sa'i lengths ("ashwaat") as the pilgrim walks back and forth between
/// Safa and Marwah — or, in the home demo, two points you mark at opposite ends
/// of the room.
///
/// Method: project the pilgrim's (x,z) position onto the line between the two
/// marked endpoints, giving a normalized parameter `s` (0 = Safa, 1 = Marwah).
/// One length completes each time the pilgrim ARRIVES at the far endpoint from
/// where they last arrived. Hysteresis (arrive within `arriveFraction` of an
/// end, and only count when it's the OPPOSITE end to last time) prevents
/// double-counting from jitter near an endpoint.
///
/// Sa'i is 7 lengths total, starting at Safa: Safa→Marwah is length 1,
/// Marwah→Safa is length 2, … so the 7th length ends at Marwah. This is purely
/// linear, so it works at living-room scale (two table corners) or full Mas'a
/// scale (the ~450 m corridor) with the same code — like TawafTracker, no
/// distance constant is baked in.
final class SaiTracker {
    enum End { case safa, marwah }

    private(set) var safa: SIMD2<Float>?      // (x, z) of the Safa endpoint
    private(set) var marwah: SIMD2<Float>?    // (x, z) of the Marwah endpoint
    private(set) var lengths: Int = 0
    private(set) var fractionOfCurrent: Float = 0   // 0..1 progress toward the next end

    /// The last endpoint the pilgrim was confirmed at. nil until the first update
    /// snaps it to whichever end they start nearest.
    private(set) var lastArrived: End?

    let totalLengths = 7

    /// Arrive when within this fraction of an endpoint (0.9 ⇒ last 10% of the leg).
    private let arriveFraction: Float = 0.9

    var isComplete: Bool { lengths >= totalLengths }

    /// The end the pilgrim should be heading toward right now (for spoken guidance).
    var nextTarget: End? {
        guard let last = lastArrived, !isComplete else { return nil }
        return last == .safa ? .marwah : .safa
    }

    /// Mark the two endpoints (from ARKit raycasts). Call `setSafa` first where the
    /// pilgrim is standing, then `setMarwah` at the far end — or set both and let the
    /// first `update` decide which end they start at.
    func setEndpoints(safa a: SIMD3<Float>, marwah b: SIMD3<Float>) {
        safa = SIMD2(a.x, a.z)
        marwah = SIMD2(b.x, b.z)
        lengths = 0
        lastArrived = nil
        fractionOfCurrent = 0
    }

    func reset() {
        safa = nil; marwah = nil
        lengths = 0; lastArrived = nil; fractionOfCurrent = 0
    }

    /// Feed the current camera/world position each frame. Returns the newly
    /// completed length number if one just completed, else nil.
    @discardableResult
    func update(cameraWorldPosition p: SIMD3<Float>) -> Int? {
        guard let a = safa, let b = marwah else { return nil }
        let ab = b - a
        let lenSq = simd_length_squared(ab)
        guard lenSq > 1e-4 else { return nil }            // endpoints coincide — ignore

        // Normalized projection of the pilgrim onto the Safa→Marwah line.
        let ap = SIMD2(p.x, p.z) - a
        let s = simd_clamp(simd_dot(ap, ab) / lenSq, 0, 1)

        // First sample: snap to the nearest end without counting.
        guard let last = lastArrived else {
            lastArrived = (s < 0.5) ? .safa : .marwah
            fractionOfCurrent = 0
            return nil
        }

        // Progress toward the end we're currently walking to.
        let target: End = (last == .safa) ? .marwah : .safa
        fractionOfCurrent = (target == .marwah) ? s : (1 - s)

        // Arrived at the OPPOSITE end? Count one length.
        let arrivedMarwah = last == .safa && s >= arriveFraction
        let arrivedSafa   = last == .marwah && s <= (1 - arriveFraction)
        if arrivedMarwah || arrivedSafa {
            lastArrived = arrivedMarwah ? .marwah : .safa
            if lengths < totalLengths {
                lengths += 1
                fractionOfCurrent = isComplete ? 1 : 0
                return lengths
            }
        }
        return nil
    }
}
