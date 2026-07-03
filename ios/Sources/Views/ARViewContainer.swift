import SwiftUI
import RealityKit
import ARKit

/// Hosts the ARKit camera passthrough and hands the ARView to the view model.
struct ARViewContainer: UIViewRepresentable {
    let viewModel: CompanionViewModel

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        viewModel.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
