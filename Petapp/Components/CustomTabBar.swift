import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    var onPawsyTap: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            WaveTabBarShape()
                .fill(PawsyTheme.backgroundCream.opacity(0.99))
                .overlay(
                    WaveTabBarShape()
                        .stroke(Color.white.opacity(0.92), lineWidth: 1)
                )
                .clipShape(RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                .shadow(color: Color.white.opacity(0.7), radius: 5, x: 0, y: -2)
                .frame(height: 96)
                .offset(y: 18)

            Button {
                withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.84)) {
                    if let onPawsyTap {
                        onPawsyTap()
                    } else {
                        selectedTab = .home
                    }
                }
            } label: {
                PawsyWordmark(fontSize: 16, iconSize: 20)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(hex: "#C8EEDB"))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.88), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .shadow(color: Color.white.opacity(0.65), radius: 3, x: 0, y: -1)
                )
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .accessibilityIdentifier("pawsy.center.pill")
            .offset(y: 2)

            HStack(spacing: 0) {
                tabButton(.home)
                tabButton(.calendar)
                tabButton(.aiChat)
                tabButton(.profile)
            }
            .padding(.horizontal, 12)
            .padding(.top, 50)
        }
        .frame(height: 126)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.86)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color(hex: "#173A2C") : Color.gray.opacity(0.72))
                Text(tab.title)
                    .font(.pawsy(11, isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(hex: "#173A2C") : Color.gray.opacity(0.72))
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(hex: "#E4F4EC") : .clear)
                    .shadow(color: isSelected ? Color.black.opacity(0.08) : .clear, radius: 6, x: 0, y: 3)
                    .shadow(color: isSelected ? Color.white.opacity(0.6) : .clear, radius: 2, x: 0, y: -1)
                    .frame(width: 74, height: 44)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tab.\(tab.testID)")
    }
}

private extension AppTab {
    var title: String {
        switch self {
        case .home: return "Home"
        case .calendar: return "Calendar"
        case .aiChat: return "AI Chat"
        case .profile: return "Profile"
        }
    }
}
