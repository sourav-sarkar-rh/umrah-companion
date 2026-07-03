import Foundation
import Vision
import ARKit
import CoreImage

/// On-device scene understanding from an ARFrame. No cloud, no key.
///
/// For the demo it detects PEOPLE (the crowd-safety story) using Vision's
/// built-in human-rectangle detector, then reads the LiDAR depth map to attach
/// a real distance and a left/ahead/right direction to each. A Core ML YOLO
/// model can be dropped in later for richer object labels — see `detectObjects`.
final class SceneVision {
    private let ciContext = CIContext()

    /// Produce structured observations for the current frame.
    func observations(from frame: ARFrame) -> [Observation] {
        let pixelBuffer = frame.capturedImage
        var results: [Observation] = []

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = false
        try? handler.perform([request])

        let depth = frame.sceneDepth?.depthMap   // LiDAR depth, if available
        for obs in (request.results ?? []) {
            let box = obs.boundingBox            // normalized, origin bottom-left
            let cx = box.midX
            let direction: Observation.Direction =
                cx < 0.4 ? .left : (cx > 0.6 ? .right : .ahead)
            let distance = depth.flatMap { distanceMeters(at: box, depthMap: $0) }
            results.append(Observation(label: "person", direction: direction, distanceM: distance))
        }
        return results
    }

    /// Sample the LiDAR depth map at the center of a normalized bounding box.
    private func distanceMeters(at box: CGRect, depthMap: CVPixelBuffer) -> Double? {
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        let w = CVPixelBufferGetWidth(depthMap)
        let h = CVPixelBufferGetHeight(depthMap)
        guard let base = CVPixelBufferGetBaseAddress(depthMap) else { return nil }
        let bpr = CVPixelBufferGetBytesPerRow(depthMap)
        let px = min(w - 1, max(0, Int(box.midX * CGFloat(w))))
        let py = min(h - 1, max(0, Int((1 - box.midY) * CGFloat(h))))   // flip y
        let rowPtr = base.advanced(by: py * bpr).assumingMemoryBound(to: Float32.self)
        let meters = rowPtr[px]
        guard meters.isFinite, meters > 0 else { return nil }
        return Double((meters * 10).rounded() / 10)   // one decimal place
    }

    /// Grab a downscaled JPEG of the current frame to send to the cloud for
    /// open-ended description. Keeps bandwidth/cost/privacy bounded — one frame,
    /// only when the pilgrim explicitly asks.
    func jpegBase64(from frame: ARFrame, maxWidth: CGFloat = 768, quality: CGFloat = 0.5) -> String? {
        var image = CIImage(cvPixelBuffer: frame.capturedImage).oriented(.right)
        let scale = min(1, maxWidth / image.extent.width)
        if scale < 1 {
            image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        }
        guard let cg = ciContext.createCGImage(image, from: image.extent) else { return nil }
        let ui = UIImage(cgImage: cg)
        return ui.jpegData(compressionQuality: quality)?.base64EncodedString()
    }
}

import UIKit
