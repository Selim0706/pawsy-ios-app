import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var color: Color
    var icon: String?
    var label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                }
            }
            .frame(width: 60, height: 60)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appDarkGreen)
        }
    }
}
