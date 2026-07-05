import SwiftUI
import UIKit

/// The one demo screen. Camera fills the background; a big legible overlay shows
/// ritual progress and the assistant state. High contrast, large touch targets,
/// VoiceOver-labeled, and fully multi-language with right-to-left support.
struct DemoView: View {
    @StateObject private var vm: CompanionViewModel
    @State private var showLaunch = true

    init(proxyBaseURL: URL) {
        _vm = StateObject(wrappedValue: CompanionViewModel(proxyBaseURL: proxyBaseURL))
    }

    private let gold = Color(red: 0.83, green: 0.68, blue: 0.33)
    private let ink = Color.black.opacity(0.55)

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: vm).ignoresSafeArea()

            VStack {
                topBar
                statusBanner
                if vm.guidanceOn && (vm.phase == .tawaf || vm.phase == .sai) { guidanceBanner }
                if !vm.detections.isEmpty { detectionReadout }
                Spacer()
                if vm.phase == .tawaf || vm.phase == .sai || vm.phase == .complete { circuitRing }
                Spacer()
                controls
            }
            .padding()
        }
        // Voice-anywhere: double-tap (sighted) + VoiceOver two-finger magic-tap (blind).
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { vm.startVoice() }
        .accessibilityAction(.magicTap) { vm.startVoice() }
        .environment(\.layoutDirection, vm.lang.layoutDirection)   // RTL for Arabic/Urdu
        .overlay { if showLaunch { LaunchView(l: vm.l).transition(.opacity) } }
        .onAppear {
            vm.onAppear()
            UIApplication.shared.isIdleTimerDisabled = true   // never auto-lock mid-Tawaf
        }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation(.easeOut(duration: 0.6)) { showLaunch = false }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: pieces
    private var topBar: some View {
        HStack {
            Menu {
                ForEach(Lang.allCases) { lg in
                    Button(lg.nativeName) { vm.setLanguage(lg) }
                }
            } label: {
                Label(vm.lang.nativeName, systemImage: "globe")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(ink, in: Capsule()).foregroundStyle(.white)
            }
            Spacer()
            if vm.speech.isSpeaking {
                Image(systemName: "waveform").symbolEffect(.variableColor).foregroundStyle(gold)
                    .font(.title3)
            }
            Button { vm.warningsMuted.toggle() } label: {
                Image(systemName: vm.warningsMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title3)
                    .foregroundStyle(vm.warningsMuted ? .red : .white.opacity(0.7))
                    .padding(8)
                    .background(ink, in: Circle())
            }
            .accessibilityLabel(vm.warningsMuted ? "Unmute obstacle warnings" : "Mute obstacle warnings")

            Button { vm.toggleGuidance() } label: {
                Image(systemName: vm.guidanceOn ? "figure.walk.circle.fill" : "figure.walk.circle")
                    .font(.title3)
                    .foregroundStyle(vm.guidanceOn ? gold : .white.opacity(0.7))
                    .padding(8)
                    .background(ink, in: Circle())
            }
            .accessibilityLabel(vm.guidanceOn ? vm.l.guideOffLabel : vm.l.guideOnLabel)

            Button { vm.cycleDua() } label: {
                Image(systemName: vm.duaMode == .recite ? "hands.sparkles.fill" : "hands.sparkles")
                    .font(.title3)
                    .foregroundStyle(vm.duaMode == .off ? .white.opacity(0.7) : gold)
                    .padding(8)
                    .background(ink, in: Circle())
            }
            .accessibilityLabel(vm.l.duaModeName(vm.duaMode.rawValue))

            Button { vm.toggleDebug() } label: {
                Image(systemName: vm.debugMesh ? "cube.transparent.fill" : "cube.transparent")
                    .font(.title3)
                    .foregroundStyle(vm.debugMesh ? gold : .white.opacity(0.7))
                    .padding(8)
                    .background(ink, in: Circle())
            }
            .accessibilityLabel("Toggle LiDAR debug view")
        }
    }

    /// Compact walk-guidance readout during Tawaf (sighted demo-runner + low-vision).
    private var guidanceBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: vm.guidanceState == .onPath ? "checkmark.circle.fill" : "arrow.triangle.turn.up.right.circle.fill")
                .foregroundStyle(vm.guidanceState == .onPath ? .green : gold)
            Text(vm.l.guidanceLabel(vm.guidanceState, steerLeft: vm.guidanceSteerLeft))
                .font(.headline).foregroundStyle(.white)
            Spacer()
        }
        .padding(12)
        .background(ink, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityHidden(true)   // the beacon + spoken cues cover this non-visually
    }

    private var statusBanner: some View {
        HStack(spacing: 10) {
            Circle().fill(vm.trackingOK ? .green : .orange).frame(width: 10, height: 10)
            Text(vm.statusLine)
                .font(.headline).foregroundStyle(.white)
                .lineLimit(2).minimumScaleFactor(0.7)
            Spacer()
        }
        .padding(14)
        .background(ink, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    /// Live "what I see" readout — the nearest detected objects with LiDAR distance.
    private var detectionReadout: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(vm.detections.prefix(3)) { o in
                HStack(spacing: 8) {
                    Image(systemName: "viewfinder").font(.caption).foregroundStyle(gold)
                    Text(vm.l.obstacleName(o.label).capitalized)
                        .foregroundStyle(.white)
                    Spacer(minLength: 8)
                    if let d = o.distanceM {
                        Text("\(vm.l.num1(d)) m").foregroundStyle(gold).monospacedDigit()
                    }
                }
                .font(.subheadline.weight(.medium))
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ink, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)   // spoken warnings cover this for VoiceOver users
    }

    private var circuitRing: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.2), lineWidth: 16)
            Circle()
                .trim(from: 0, to: CGFloat(vm.count) / 7 + CGFloat(vm.circuitProgress) / 7)
                .stroke(gold, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: vm.count)
            VStack(spacing: 2) {
                Text(vm.l.num(vm.count))
                    .font(.system(size: 68, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text(vm.ritual == .tawaf ? vm.l.ofSevenCircuits : vm.l.ofSevenLengths)
                    .font(.title3).foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(width: 220, height: 220)
        .accessibilityLabel("\(vm.count) / 7")
        .accessibilityValue(vm.phase == .complete ? (vm.ritual == .tawaf ? vm.l.tawafComplete : vm.l.saiComplete) : "")
    }

    private var markLabel: String { vm.ritual == .tawaf ? vm.l.markButton : vm.l.markHereButton }

    private var controls: some View {
        VStack(spacing: 14) {
            if let o = vm.nearestObstacle, let d = o.distanceM {
                Label(vm.l.obstacleChip(o.label, o.direction, d), systemImage: "figure.walk.motion")
                    .font(.subheadline.weight(.semibold))
                    .padding(10)
                    .background(.red.opacity(0.85), in: Capsule())
                    .foregroundStyle(.white)
            }

            HStack(spacing: 14) {
                switch vm.phase {
                case .idle:
                    bigButton(vm.l.tawafName, "circle.circle", gold) { vm.selectRitual(.tawaf) }
                    bigButton(vm.l.saiName, "arrow.left.arrow.right", .green) { vm.selectRitual(.sai) }
                case .marking, .markingSecond:
                    bigButton(markLabel, "scope", gold) { vm.markCenter() }
                case .tawaf, .sai:
                    bigButton(vm.speech.isListening ? vm.l.listening : vm.l.askButton,
                              "mic.fill", .blue) { vm.startVoice() }
                case .complete:
                    bigButton(vm.l.startAgain, "arrow.counterclockwise", gold) { vm.restart() }
                }
            }
        }
    }

    private func bigButton(_ title: String, _ icon: String, _ tint: Color,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity).frame(height: 62)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .accessibilityHint(title)
    }
}
