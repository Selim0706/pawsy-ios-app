import SwiftUI

struct ActionButton: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let color: Color
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(PawsyTheme.textPrimary)
                Text(title)
                    .font(.pawsy(14, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                Text(subtitle ?? "Ready")
                    .font(.pawsy(10, .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 102, height: 86)
            .bubbleStrong(radius: 18, fill: color.opacity(isDisabled ? 0.55 : 0.82))
            .opacity(isDisabled ? 0.82 : 1)
        }
        .buttonStyle(PressableBubbleButtonStyle())
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityIdentifier("action.\(title.lowercased())")
    }
}
