import Foundation
import Vision
import CoreML
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

    /// The bundled YOLOv8n object detector (80 everyday classes), loaded once.
    /// nil if the model isn't in the bundle — we then fall back to people-only.
    private lazy var yolo: VNCoreMLModel? = Self.loadYOLO()

    private static func loadYOLO() -> VNCoreMLModel? {
        guard let url = Bundle.main.url(forResource: "yolov8n", withExtension: "mlmodelc") else { return nil }
        do {
            let model = try MLModel(contentsOf: url, configuration: MLModelConfiguration())
            return try VNCoreMLModel(for: model)
        } catch {
            return nil
        }
    }

    /// Produce structured observations for the current frame: a label, a rough
    /// left/ahead/right direction, and a LiDAR distance for each detected thing.
    func observations(from frame: ARFrame) -> [Observation] {
        let depth = frame.sceneDepth?.depthMap   // LiDAR depth, if available
        if let yolo {
            return detectObjects(from: frame, model: yolo, depth: depth)
        }
        return detectPeople(from: frame, depth: depth)   // fallback if the model is missing
    }

    /// YOLO object detection → observations (person, chair, bottle, backpack, …).
    private func detectObjects(from frame: ARFrame, model: VNCoreMLModel,
                               depth: CVPixelBuffer?) -> [Observation] {
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .right, options: [:])
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFill   // keep the full field of view for left/right
        try? handler.perform([request])

        var results: [Observation] = []
        for case let obs as VNRecognizedObjectObservation in (request.results ?? []) {
            guard let top = obs.labels.first, top.confidence >= 0.35 else { continue }
            let box = obs.boundingBox
            let cx = box.midX
            let direction: Observation.Direction = cx < 0.4 ? .left : (cx > 0.6 ? .right : .ahead)
            let distance = depth.flatMap { distanceMeters(at: box, depthMap: $0) }
            results.append(Observation(label: top.identifier, direction: direction, distanceM: distance))
        }
        return results
    }

    /// Fallback: Apple's built-in human detector (used only if the YOLO model is absent).
    private func detectPeople(from frame: ARFrame, depth: CVPixelBuffer?) -> [Observation] {
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .right, options: [:])
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = false
        try? handler.perform([request])

        var results: [Observation] = []
        for obs in (request.results ?? []) {
            let box = obs.boundingBox
            let cx = box.midX
            let direction: Observation.Direction = cx < 0.4 ? .left : (cx > 0.6 ? .right : .ahead)
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
