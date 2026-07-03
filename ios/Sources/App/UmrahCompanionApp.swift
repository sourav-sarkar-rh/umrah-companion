import SwiftUI

@main
struct UmrahCompanionApp: App {
    // Point this at the FastAPI proxy on your Mac (same wifi as the phone).
    // Find your Mac's IP: System Settings ▸ Wi-Fi ▸ Details ▸ IP address,
    // or run `ipconfig getifaddr en0` in Terminal.
    static let proxyURL = URL(string: "http://192.168.1.100:8077")!

    var body: some Scene {
        WindowGroup {
            DemoView(proxyBaseURL: Self.proxyURL)
        }
    }
}
