import SwiftUI

struct PawsyHubSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    var onOpenSettings: (() -> Void)?
    var onOpenHistory: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        GlassCard(radius: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pawsy Hub")
                                    .font(.pawsy(20, .bold))
                                Text("Today Progress: \(Int((viewModel.dailyProgress * 100).rounded()))%")
                                    .font(.pawsy(14, .semibold))
                                    .foregroundStyle(PawsyTheme.textSecondary)

                                ProgressView(value: viewModel.dailyProgress)
                                    .tint(PawsyTheme.accentEmerald)

                                HStack(spacing: 8) {
                                    Label(viewModel.moodText, systemImage: "face.smiling")
                                    Label("Energy \(viewModel.petState.vitals.energy)", systemImage: "bolt.fill")
                                    Label("Hunger \(viewModel.petState.vitals.hunger)", systemImage: "fork.knife")
                                }
                                .font(.pawsy(12, .semibold))
                                .foregroundStyle(PawsyTheme.textSecondary)
                            }
                        }

                        if viewModel.canShowPerfectCareBadge {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Perfect Care Day")
                            }
                            .font(.pawsy(14, .bold))
                            .foregroundStyle(Color(hex: "#227B57"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .bubbleSoft(radius: 14, fill: Color(hex: "#E5F8EF"))
                        }

                        GlassCard(radius: 20) {
                            HStack(spacing: 10) {
                                Button {
                                    dismiss()
                                    onOpenSettings?()
                                } label: {
                                    Label("Open Pet Settings", systemImage: "slider.horizontal.3")
                                        .font(.pawsy(13, .semibold))
                                        .foregroundStyle(PawsyTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .bubbleSoft(radius: 14, fill: Color.white.opacity(0.72))
                                }
                                .buttonStyle(PressableBubbleButtonStyle())

                                Button {
                                    dismiss()
                                    onOpenHistory?()
                                } label: {
                                    Label("History", systemImage: "clock")
                                        .font(.pawsy(13, .semibold))
                                        .foregroundStyle(PawsyTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .bubbleSoft(radius: 14, fill: Color.white.opacity(0.72))
                                }
                                .buttonStyle(PressableBubbleButtonStyle())
                            }
                        }

                        ForEach(viewModel.tasks) { task in
                            HStack(spacing: 12) {
                                Image(systemName: task.icon)
                                    .frame(width: 28, height: 28)
                                    .foregroundStyle(PawsyTheme.textPrimary)
                                    .bubble(radius: 10, fill: Color.white.opacity(0.65))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title)
                                        .font(.pawsy(15, .semibold))
                                        .foregroundStyle(PawsyTheme.textPrimary)
                                    if let completedAt = task.completedAt {
                                        Text("Done at \(completedAt.formatted(date: .omitted, time: .shortened))")
                                            .font(.pawsy(11, .medium))
                                            .foregroundStyle(PawsyTheme.textSecondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isDone ? PawsyTheme.accentEmerald : PawsyTheme.textSecondary)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .padding(12)
                            .bubbleSoft(radius: 18, fill: task.isDone ? Color(hex: "#E5F8EF") : Color.white.opacity(0.68))
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Daily Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
