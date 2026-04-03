import SwiftUI
import Charts

struct GlassCard<Content: View>: View {
    let radius: CGFloat
    @ViewBuilder var content: Content

    init(radius: CGFloat = PawsyTheme.radiusCard, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .bubbleSoft(radius: radius)
    }
}

struct CalendarCard: View {
    let monthTitle: String
    let selectedDay: Int
    let markedDays: Set<Int>
    let selectDay: (Int) -> Void

    private let weekDays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    private let days = Array(1...31)

    var body: some View {
        GlassCard(radius: 24) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "chevron.left")
                    Spacer()
                    Text(monthTitle)
                        .font(.pawsy(18, .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(PawsyTheme.textPrimary)

                HStack {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.pawsy(13, .medium))
                            .foregroundStyle(PawsyTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(days, id: \.self) { day in
                        Button {
                            selectDay(day)
                        } label: {
                            VStack(spacing: 1) {
                                Text("\(day)")
                                    .font(.pawsy(14, .medium))
                                    .foregroundStyle(PawsyTheme.textPrimary)
                                    .frame(width: 28, height: 22)
                                    .background(
                                        Circle()
                                            .fill(day == selectedDay ? PawsyTheme.accentGreen : .clear)
                                    )
                                Circle()
                                    .fill(markedDays.contains(day) ? PawsyTheme.accentEmerald : .clear)
                                    .frame(width: 5, height: 5)
                            }
                            .frame(width: 28, height: 30)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct WeightChartCard: View {
    let points: [WeightPoint]

    var body: some View {
        GlassCard(radius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Weight History")
                    .font(.pawsy(16, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)

                Chart(points) { point in
                    LineMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Weight", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: "#98D7C2"), Color(hex: "#EAA991")], startPoint: .leading, endPoint: .trailing)
                    )

                    AreaMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Weight", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: "#98D7C2").opacity(0.35), .clear], startPoint: .top, endPoint: .bottom)
                    )
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .user { Spacer(minLength: 34) }

            if message.sender == .ai {
                miniAvatar
            }

            VStack(alignment: .leading, spacing: 8) {
                if let imageData = message.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 106)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                HStack(alignment: .top, spacing: 6) {
                    if message.isWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                    Text(message.text)
                        .font(.pawsy(14, .medium))
                        .foregroundStyle(Color(hex: "#2D3436"))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(message.sender == .user ? Color(hex: "#BDEEDC") : Color(hex: "#FFDCCF"))
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            )

            if message.sender == .ai { Spacer(minLength: 34) }
        }
        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
    }

    private var miniAvatar: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 28, height: 28)
            .overlay(Text("🤖").font(.pawsy(12, .semibold)))
    }
}

struct PetCard: View {
    let pet: PetProfile
    let isActive: Bool

    var body: some View {
        VStack(spacing: 10) {
            Group {
                if UIImage(named: pet.avatarAsset) != nil {
                    Image(pet.avatarAsset)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text("🐶")
                        .font(.pawsy(42, .bold))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(PawsyTheme.accentGreen.opacity(0.6))
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(pet.name)
                .font(.pawsy(14, .semibold))
                .foregroundStyle(PawsyTheme.textPrimary)

            Text(pet.species.title)
                .font(.pawsy(11, .medium))
                .foregroundStyle(PawsyTheme.textSecondary)
        }
        .frame(width: 118)
        .padding(.vertical, 10)
        .bubble(radius: 20, fill: isActive ? PawsyTheme.accentGreen.opacity(0.55) : Color.white.opacity(0.72))
    }
}

struct BubbleSelectionRow: View {
    let title: String
    let value: String
    var valueColor: Color = PawsyTheme.textPrimary
    var icon: String = "chevron.down"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.pawsy(12, .semibold))
                        .foregroundStyle(PawsyTheme.textSecondary)
                    Text(value)
                        .font(.pawsy(15, .semibold))
                        .foregroundStyle(valueColor)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .bubble(radius: 14, fill: Color.white.opacity(0.78))
        }
        .buttonStyle(PressableBubbleButtonStyle())
    }
}

struct BubbleToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.pawsy(15, .semibold))
                        .foregroundStyle(PawsyTheme.textPrimary)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.pawsy(12, .medium))
                            .foregroundStyle(PawsyTheme.textSecondary)
                    }
                }

                Spacer()

                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn ? PawsyTheme.accentGreen.opacity(0.9) : Color.white.opacity(0.9))
                        .frame(width: 54, height: 30)
                        .overlay(
                            Capsule()
                                .stroke(PawsyTheme.glassStroke, lineWidth: 1)
                        )

                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 24, height: 24)
                        .padding(3)
                        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .bubble(radius: 14, fill: Color.white.opacity(0.78))
        }
        .buttonStyle(PressableBubbleButtonStyle())
    }
}

struct SelectionListSheet: View {
    let title: String
    let options: [String]
    let selected: String
    let onPick: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filtered: [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return options }
        return options.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 10) {
                    TextField("Search", text: $query)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .bubble(radius: 14, fill: Color.white.opacity(0.82))

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(filtered, id: \.self) { item in
                                Button {
                                    onPick(item)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text(item)
                                            .font(.pawsy(15, .semibold))
                                            .foregroundStyle(PawsyTheme.textPrimary)
                                        Spacer()
                                        if item == selected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(PawsyTheme.accentEmerald)
                                        }
                                    }
                                    .padding(12)
                                    .bubble(radius: 14, fill: Color.white.opacity(0.74))
                                }
                                .buttonStyle(PressableBubbleButtonStyle())
                            }
                        }
                    }
                }
                .padding(PawsyTheme.horizontalPadding)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DateSelectionSheet: View {
    let title: String
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 18) {
                    DatePicker(
                        title,
                        selection: $date,
                        displayedComponents: displayedComponents
                    )
                    .datePickerStyle(.graphical)
                    .padding(12)
                    .bubble(radius: 22, fill: Color.white.opacity(0.78))

                    Button("Done") { dismiss() }
                        .font(.pawsy(15, .bold))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .bubbleStrong(radius: 16, fill: PawsyTheme.accentGreen.opacity(0.82))
                        .buttonStyle(PressableBubbleButtonStyle())
                }
                .padding(PawsyTheme.horizontalPadding)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
