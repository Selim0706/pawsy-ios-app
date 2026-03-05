import SwiftUI

struct StatRing: View {
    let progress: Double
    let color: Color
    let title: String

    var body: some View {
        VStack(spacing: 9) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.pawsy(18, .black))
                    .foregroundStyle(PawsyTheme.textPrimary)
            }
            .frame(width: 72, height: 72)

            Text(localizedTitle)
                .font(.pawsy(14, .bold))
                .foregroundStyle(PawsyTheme.textPrimary)
        }
    }

    private var localizedTitle: String {
        switch title.lowercased() {
        case "happiness": return "Happiness"
        case "health": return "Health"
        case "hygiene": return "Hygiene"
        default: return title
        }
    }
}
