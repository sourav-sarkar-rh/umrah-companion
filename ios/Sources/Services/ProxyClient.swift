import Foundation

/// Talks to the FastAPI scene-description proxy running on the Mac.
/// Set `baseURL` to your Mac's LAN address, e.g. http://192.168.1.42:8077
actor ProxyClient {
    var baseURL: URL

    init(baseURL: URL) { self.baseURL = baseURL }

    /// Sends structured observations (+ optional JPEG frame) and returns one
    /// short spoken sentence. Throws on network/HTTP error so the caller can
    /// fall back to on-device narration.
    func describe(_ request: DescribeRequest) async throws -> DescribeResponse {
        var req = URLRequest(url: baseURL.appendingPathComponent("describe"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20
        req.httpBody = try JSONEncoder().encode(request)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(DescribeResponse.self, from: data)
    }

    func health() async -> Bool {
        var req = URLRequest(url: baseURL.appendingPathComponent("health"))
        req.timeoutInterval = 4
        guard let (_, resp) = try? await URLSession.shared.data(for: req),
              let http = resp as? HTTPURLResponse else { return false }
        return http.statusCode == 200
    }
}
