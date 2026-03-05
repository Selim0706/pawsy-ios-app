import SwiftUI

@main
struct PetappApp: App {
    @State private var showSplash = true
    @State private var splashPulse = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    PawsySplashView(isPulsing: splashPulse)
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                        .zIndex(2)
                }
            }
            .onAppear {
                splashPulse = true
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.7))
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

private struct PawsySplashView: View {
    let isPulsing: Bool
    @State private var floatCard = false

    var body: some View {
        ZStack {
            AppBackground()

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 76, height: 76)
                .offset(x: -120, y: -170)

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 58, height: 58)
                .offset(x: 126, y: -140)

            Circle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 42, height: 42)
                .offset(x: 140, y: 150)

            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .fill(Color.white.opacity(0.24))
                        .frame(width: 180, height: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 46, style: .continuous)
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        )
                        .shadow(color: .white.opacity(0.6), radius: 10, x: -3, y: -3)
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 6, y: 10)

                    Image("PawsyMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

                Text("Pawsy")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
            }
            .scaleEffect(isPulsing ? 1.015 : 0.985)
            .offset(y: floatCard ? -4 : 5)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floatCard)
            .onAppear { floatCard = true }
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("splash.screen")
    }
}
