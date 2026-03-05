import SwiftUI
import PhotosUI

struct AIAssistantView: View {
    @ObservedObject var viewModel: AIAssistantViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var petProfiles: PetProfilesViewModel
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#F6EDE1").ignoresSafeArea()

            TopCurveShape()
                .fill(PawsyTheme.backgroundMint)
                .frame(height: 245)
                .ignoresSafeArea()

            VStack(spacing: PawsyTheme.sectionSpacing) {
                header

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        if viewModel.messages.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "message.badge")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(PawsyTheme.textSecondary)
                                Text("Start a new conversation")
                                    .font(.pawsy(14, .semibold))
                                    .foregroundStyle(PawsyTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 180)
                            .accessibilityIdentifier("ai.empty.messages")
                        } else {
                            VStack(spacing: 14) {
                                ForEach(viewModel.messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, PawsyTheme.horizontalPadding)
                            .padding(.top, 6)
                            .padding(.bottom, 10)
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }

                inputBar
                    .padding(.horizontal, PawsyTheme.horizontalPadding)
                    .padding(.bottom, router.isTabBarVisible ? 110 : 18)
                    .animation(.spring(response: 0.34, dampingFraction: 0.86), value: router.isTabBarVisible)
            }
            .padding(.top, 10)
        }
        .accessibilityIdentifier("screen.ai")
        .onChange(of: selectedPhoto) { _, _ in
            Task {
                await viewModel.attachPhoto(selectedPhoto)
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                router.goHome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .bubble(radius: 16, fill: Color.white.opacity(0.45))
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .accessibilityIdentifier("ai.back")

            Spacer()

            VStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: "#F4EADF"))
                    .frame(width: 72, height: 72)
                    .overlay(Text("🤖").font(.pawsy(34, .medium)))
                Text("Ask Vetty AI")
                    .font(.pawsy(22, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .accessibilityIdentifier("title.ai")
                Text("for \(petProfiles.activePet?.name ?? "your pet")")
                    .font(.pawsy(12, .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .bubble(radius: 16, fill: Color.white.opacity(0.45))
            }
            .buttonStyle(PressableBubbleButtonStyle())
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
        .padding(.bottom, 2)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("Type message...", text: $viewModel.draft)
                    .font(.pawsy(15, .medium))
                    .foregroundStyle(PawsyTheme.textPrimary)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "photo")
                        .foregroundStyle(PawsyTheme.textSecondary)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel("Attach photo")
                .accessibilityIdentifier("ai.photo.picker")

                Button(action: {}) {
                    Image(systemName: "face.smiling")
                        .foregroundStyle(PawsyTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .bubble(radius: 24, fill: Color.white)

            Button {
                viewModel.send(text: viewModel.draft)
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Color(hex: "#4A7F6E"))
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color(hex: "#BFEADA"))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .accessibilityLabel("Send message")
            .accessibilityIdentifier("ai.send")
        }
    }
}

#Preview {
    let profiles = PetProfilesViewModel()
    AIAssistantView(viewModel: AIAssistantViewModel(repository: InMemoryMockRepository(), petProfiles: profiles))
        .environmentObject(profiles)
        .environmentObject(AppRouter())
}
