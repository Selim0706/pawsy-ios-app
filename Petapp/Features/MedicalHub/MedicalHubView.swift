import SwiftUI

struct MedicalHubView: View {
    @ObservedObject var viewModel: MedicalHubViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var petProfiles: PetProfilesViewModel

    @State private var isAddingReminder = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#F6EDE1").ignoresSafeArea()

            TopCurveShape()
                .fill(PawsyTheme.backgroundMint)
                .frame(height: 220)
                .ignoresSafeArea()

            VStack(spacing: PawsyTheme.sectionSpacing) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawsyTheme.sectionSpacing) {
                        CalendarCard(
                            monthTitle: viewModel.monthTitle,
                            selectedDay: viewModel.selectedDate,
                            markedDays: viewModel.markedReminderDays,
                            selectDay: viewModel.selectDate
                        )

                        if viewModel.weightPoints.isEmpty {
                            GlassCard(radius: 24) {
                                VStack(spacing: 8) {
                                    Image(systemName: "waveform.path.ecg")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                    Text("No weight history yet")
                                        .font(.pawsy(14, .semibold))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 120)
                            }
                        } else {
                            WeightChartCard(points: viewModel.weightPoints)
                        }

                        remindersSection
                        servicesSection
                    }
                    .padding(.horizontal, PawsyTheme.horizontalPadding)
                    .padding(.bottom, 120)
                }
            }
            .padding(.top, 8)
        }
        .accessibilityIdentifier("screen.medical")
        .sheet(item: $viewModel.selectedEvent) { event in
            MedicalEventDetailSheet(
                event: event,
                isCompleted: viewModel.isCompleted(event),
                onMarkDone: { viewModel.markSelectedEventDone() }
            )
            .presentationDetents([.fraction(0.34), .medium])
        }
        .sheet(isPresented: $isAddingReminder) {
            AddReminderSheet(
                defaultDay: viewModel.selectedDate,
                onSave: { title, category, date, note in
                    viewModel.addReminder(title: title, category: category, date: date, note: note)
                    isAddingReminder = false
                }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private var remindersSection: some View {
        GlassCard(radius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Reminders")
                        .font(.pawsy(16, .semibold))
                        .foregroundStyle(PawsyTheme.textPrimary)

                    Spacer()

                    Button {
                        isAddingReminder = true
                    } label: {
                        Label("Add", systemImage: "plus")
                            .font(.pawsy(13, .bold))
                            .foregroundStyle(PawsyTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .bubble(radius: 12, fill: PawsyTheme.accentGreen)
                    }
                    .buttonStyle(PressableBubbleButtonStyle())
                    .accessibilityIdentifier("medical.add.reminder")
                }

                if viewModel.remindersForSelectedDay.isEmpty {
                    let dateLabel = "No reminders on day \(viewModel.selectedDate)"
                    Text(dateLabel)
                        .font(.pawsy(13, .semibold))
                        .foregroundStyle(PawsyTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.remindersForSelectedDay) { reminder in
                            reminderRow(reminder)
                        }
                    }
                }
            }
        }
    }

    private var servicesSection: some View {
        GlassCard(radius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Nearby Services")
                    .font(.pawsy(16, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)

                HStack(spacing: 8) {
                    serviceFilterButton(title: "All", selected: viewModel.serviceFilter == nil) {
                        viewModel.serviceFilter = nil
                    }
                    serviceFilterButton(title: "Vet", selected: viewModel.serviceFilter == .veterinary) {
                        viewModel.serviceFilter = .veterinary
                    }
                    serviceFilterButton(title: "Pet Shop", selected: viewModel.serviceFilter == .petShop) {
                        viewModel.serviceFilter = .petShop
                    }
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.filteredServices) { service in
                        HStack(spacing: 10) {
                            Image(systemName: service.type.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(PawsyTheme.textPrimary)
                                .frame(width: 34, height: 34)
                                .bubble(radius: 12, fill: PawsyTheme.accentBlue)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(service.name)
                                    .font(.pawsy(14, .semibold))
                                    .foregroundStyle(PawsyTheme.textPrimary)
                                Text("\(service.address) • \(String(format: "%.1f", service.distanceKM)) km")
                                    .font(.pawsy(11, .medium))
                                    .foregroundStyle(PawsyTheme.textSecondary)
                            }

                            Spacer()

                            Text(service.isOpenNow ? "Open" : "Closed")
                                .font(.pawsy(11, .bold))
                                .foregroundStyle(service.isOpenNow ? Color.green.opacity(0.9) : PawsyTheme.textSecondary)
                        }
                        .padding(10)
                        .bubble(radius: 16)
                    }
                }
            }
        }
    }

    private func reminderRow(_ reminder: MedicalReminder) -> some View {
        HStack(spacing: 10) {
            Button {
                viewModel.toggleReminderDone(reminder)
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(reminder.isCompleted ? Color.green.opacity(0.9) : PawsyTheme.textSecondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(reminder.title)
                    .font(.pawsy(14, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .strikethrough(reminder.isCompleted, color: PawsyTheme.textSecondary)

                Text(reminder.category.title)
                    .font(.pawsy(11, .bold))
                    .foregroundStyle(PawsyTheme.textSecondary)
            }

            Spacer()

            Text(Self.timeFormatter.string(from: reminder.date))
                .font(.pawsy(11, .bold))
                .foregroundStyle(PawsyTheme.textSecondary)

            Button {
                viewModel.deleteReminder(reminder)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.red.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .bubble(radius: 10, fill: Color(hex: "#FFE3E0"))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .bubble(radius: 16)
    }

    private func serviceFilterButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.pawsy(12, .bold))
                .foregroundStyle(PawsyTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .bubble(radius: 12, fill: selected ? PawsyTheme.accentGreen.opacity(0.9) : Color.white.opacity(0.64))
        }
        .buttonStyle(PressableBubbleButtonStyle())
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private var header: some View {
        HStack {
            Button {
                router.goHome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .glass(radius: 15)
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .accessibilityIdentifier("medical.back")

            Spacer()

            VStack(spacing: 2) {
                Text("Medical Hub")
                    .font(.pawsy(22, .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .accessibilityIdentifier("title.medical")
                Text(petProfiles.activePet?.name ?? "No pet")
                    .font(.pawsy(12, .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)
            }

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }
}

private struct AddReminderSheet: View {
    let defaultDay: Int
    let onSave: (String, ReminderCategory, Date, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var category: ReminderCategory = .vaccination
    @State private var date: Date = .now
    @State private var note: String = ""

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Reminder")
                        .font(.pawsy(22, .black))
                        .foregroundStyle(PawsyTheme.textPrimary)

                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                        .font(.pawsy(14, .medium))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .padding(12)
                        .bubble(radius: 16)

                    Picker("Category", selection: $category) {
                        ForEach(ReminderCategory.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date & Time", selection: $date)
                        .datePickerStyle(.compact)
                        .font(.pawsy(14, .medium))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .padding(12)
                        .bubble(radius: 16)

                    TextField("Notes (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .font(.pawsy(13, .medium))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .padding(12)
                        .bubble(radius: 16)

                    HStack(spacing: 10) {
                        Button("Cancel") { dismiss() }
                            .font(.pawsy(14, .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .bubble(radius: 12)

                        Button("Save Reminder") {
                            onSave(title, category, date, note)
                        }
                        .font(.pawsy(14, .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .bubble(radius: 12, fill: PawsyTheme.accentGreen)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(PawsyTheme.horizontalPadding)
            }
        }
        .onAppear {
            var components = Calendar.current.dateComponents([.year, .month], from: .now)
            components.day = max(1, min(28, defaultDay))
            if let target = Calendar.current.date(from: components) {
                date = target
            }
        }
    }
}

private struct MedicalEventDetailSheet: View {
    let event: VetEvent
    let isCompleted: Bool
    let onMarkDone: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: event.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 38, height: 38)
                        .bubble(radius: 12, fill: PawsyTheme.accentBlue)
                    Text(event.title)
                        .font(.pawsy(20, .black))
                        .foregroundStyle(PawsyTheme.textPrimary)
                }
                Text("\(event.subtitle) • \(dateFormatter.string(from: event.date))")
                    .font(.pawsy(14, .medium))
                    .foregroundStyle(PawsyTheme.textSecondary)

                HStack(spacing: 10) {
                    Button("Close") { dismiss() }
                        .font(.pawsy(15, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .bubble(radius: 12)

                    if !isCompleted {
                        Button("Mark as Done") {
                            onMarkDone()
                            dismiss()
                        }
                        .font(.pawsy(15, .bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .bubble(radius: 12, fill: PawsyTheme.accentGreen)
                    } else {
                        Text("Completed")
                            .font(.pawsy(15, .bold))
                            .foregroundStyle(Color.green.opacity(0.9))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .bubble(radius: 12, fill: Color.white.opacity(0.75))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PawsyTheme.horizontalPadding)
        }
    }
}

#Preview {
    let profiles = PetProfilesViewModel()
    MedicalHubView(viewModel: MedicalHubViewModel(repository: InMemoryMockRepository(), petProfiles: profiles))
        .environmentObject(profiles)
        .environmentObject(AppRouter())
}
