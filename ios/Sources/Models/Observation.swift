import Foundation

/// A single thing the phone noticed on-device: a label, a rough direction, and
/// (when LiDAR/depth is available) a distance in meters. These structured
/// observations — NOT raw video — are what we send to the cloud for reasoning.
struct Observation: Codable, Identifiable, Equatable {
    enum Direction: String, Codable { case left, ahead, right }

    var id = UUID()
    let label: String
    let direction: Direction
    let distanceM: Double?

    enum CodingKeys: String, CodingKey {
        case label, direction
        case distanceM = "distance_m"
    }
}

/// Request/response for the /describe endpoint on the FastAPI proxy.
struct DescribeRequest: Codable {
    let observations: [Observation]
    let language: String
    let circuit: Int?
    let question: String?
    let imageB64: String?

    enum CodingKeys: String, CodingKey {
        case observations, language, circuit, question
        case imageB64 = "image_b64"
    }
}

struct DescribeResponse: Codable {
    let text: String
    let provider: String
    let model: String?
}
