import Foundation
import simd

/// Counts Tawaf circuits from the pilgrim's motion around a center point
/// (the Kaaba — or, in the home demo, the table you mark).
///
/// Method: project the pilgrim's position onto the horizontal (x,z) plane,
/// measure the angle to the marked center, and accumulate the UNWRAPPED angle
/// as they move. Every full -2π sweep (counter-clockwise) = one completed circuit.
/// This matches the architecture doc's heuristic and works at any loop radius,
/// so a small table loop counts just like the wide Mataf.
final class TawafTracker {
    private(set) var center: SIMD2<Float>?     // (x, z) of the marked center
    private(set) var circuits: Int = 0
    private(set) var fractionOfCurrent: Float = 0   // 0..1 progress through current circuit

    private var accumulatedAngle: Float = 0    // radians, unwrapped (CCW negative in ARKit's frame)
    private var lastAngle: Float?

    let totalCircuits = 7

    var isComplete: Bool { circuits >= totalCircuits }

    /// Mark the center you'll walk around (from an ARKit raycast against the table/floor).
    func setCenter(worldPosition p: SIMD3<Float>) {
        center = SIMD2(p.x, p.z)
        accumulatedAngle = 0
        lastAngle = nil
        circuits = 0
        fractionOfCurrent = 0
    }

    func reset() {
        center = nil; lastAngle = nil; accumulatedAngle = 0
        circuits = 0; fractionOfCurrent = 0
    }

    /// Feed the current camera/world position each frame. Returns the newly
    /// completed circuit number if one just completed, else nil.
    @discardableResult
    func update(cameraWorldPosition p: SIMD3<Float>) -> Int? {
        guard let c = center else { return nil }
        let v = SIMD2(p.x, p.z) - c
        guard simd_length(v) > 0.15 else { return nil }   // ignore jitter near the center
        let angle = atan2(v.y, v.x)                        // v.y is world z here

        defer { lastAngle = angle }
        guard let last = lastAngle else { return nil }

        // shortest signed delta, unwrapped
        var delta = angle - last
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }
        accumulatedAngle += delta

        // Counter-clockwise Tawaf accumulates negative angle in ARKit's right-handed frame.
        let sweeps = Int(floor(-accumulatedAngle / (2 * .pi)))
        let clamped = max(0, min(totalCircuits, sweeps))
        fractionOfCurrent = min(1, max(0, (-accumulatedAngle / (2 * .pi)) - Float(clamped)))

        if clamped > circuits {
            circuits = clamped
            return circuits
        }
        return nil
    }
}
