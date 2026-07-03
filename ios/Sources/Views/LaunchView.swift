import SwiftUI

private let gold = Color(red: 0.83, green: 0.68, blue: 0.33)
private let teal = Color(red: 0.06, green: 0.33, blue: 0.32)
private let deepTeal = Color(red: 0.03, green: 0.17, blue: 0.16)

/// A vector echo of the app icon: gold "voice" rings around a Kaaba mark.
struct BrandMark: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(gold.opacity(0.65 - Double(i) * 0.18), lineWidth: 3)
                    .padding(CGFloat(i) * 18)
            }
            RoundedRectangle(cornerRadius: 8)
                .fill(.black)
                .frame(width: 64, height: 64)
                .overlay(Rectangle().fill(gold).frame(height: 9).offset(y: -13))
        }
    }
}

/// Brand splash shown briefly on launch — greets the user in their language.
struct LaunchView: View {
    let l: L10n
    var body: some View {
        ZStack {
            LinearGradient(colors: [teal, deepTeal], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 22) {
                BrandMark().frame(width: 150, height: 150)
                Text(l.appName)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(l.tagline)
                    .font(.title3)
                    .foregroundStyle(gold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}
