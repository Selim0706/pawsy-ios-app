import SwiftUI
import MapKit

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var petProfiles: PetProfilesViewModel
    @State private var selectedPet: PetProfile?
    @State private var isAddingPet = false
    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#F6EDE1").ignoresSafeArea()

            TopCurveShape()
                .fill(PawsyTheme.backgroundMint)
                .frame(height: 250)
                .ignoresSafeArea()

            VStack(spacing: PawsyTheme.sectionSpacing) {
                header

                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 96, height: 96)
                        .overlay(Text("🐶").font(.pawsy(42, .medium)))

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PawsyTheme.accentBlue)
                        .frame(width: 126, height: 24)
                        .overlay(
                            Circle()
                                .fill(Color(hex: "#88D79D"))
                                .frame(width: 18, height: 18)
                                .offset(x: 56)
                        )
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawsyTheme.sectionSpacing) {
                        GlassCard(radius: 24) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("My Pets")
                                        .font(.pawsy(16, .semibold))
                                    Spacer()
                                    Button {
                                        isAddingPet = true
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(PawsyTheme.textPrimary)
                                            .frame(width: 30, height: 30)
                                            .bubble(radius: 12, fill: PawsyTheme.accentGreen.opacity(0.8))
                                    }
                                    .buttonStyle(PressableBubbleButtonStyle())
                                    .accessibilityIdentifier("profile.add.pet")
                                }

                                if viewModel.pets.isEmpty {
                                    Text("No pets added yet")
                                        .font(.pawsy(14, .semibold))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                        .frame(maxWidth: .infinity, minHeight: 84)
                                        .accessibilityIdentifier("profile.empty.pets")
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.pets) { pet in
                                                Button {
                                                    viewModel.setActivePet(pet.id)
                                                    selectedPet = pet
                                                } label: {
                                                    PetCard(
                                                        pet: pet,
                                                        isActive: viewModel.activePet?.id == pet.id
                                                    )
                                                }
                                                .buttonStyle(PressableBubbleButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(PawsyTheme.textPrimary)
                        }

                        GlassCard(radius: 24) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Community Map")
                                    .font(.pawsy(16, .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .bubble(radius: 14, fill: PawsyTheme.accentGreen)

                                if viewModel.nearbyUsers.isEmpty {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.white.opacity(0.7))
                                        .overlay(
                                            Text("No community users nearby")
                                                .font(.pawsy(14, .semibold))
                                                .foregroundStyle(PawsyTheme.textSecondary)
                                        )
                                        .frame(height: 130)
                                        .accessibilityIdentifier("profile.empty.community")
                                } else {
                                    ZStack(alignment: .topLeading) {
                                        Map(position: $mapPosition, interactionModes: .all) {
                                            ForEach(viewModel.nearbyUsers) { user in
                                                Annotation("", coordinate: user.coordinate) {
                                                    Text(user.avatarEmoji)
                                                        .font(.pawsy(18, .medium))
                                                        .frame(width: 34, height: 34)
                                                        .background(Color.white.opacity(0.95))
                                                        .clipShape(Circle())
                                                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                                }
                                                .annotationTitles(.hidden)
                                            }
                                        }
                                        .onMapCameraChange(frequency: .onEnd) { context in
                                            viewModel.updateRegion(context.region)
                                        }
                                        .onAppear {
                                            if case .automatic = mapPosition {
                                                mapPosition = .region(viewModel.region)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .frame(height: 172)

                                        HStack(spacing: 8) {
                                            ForEach(Array(viewModel.nearbyUsers.prefix(4))) { user in
                                                Text(user.avatarEmoji)
                                                    .font(.pawsy(16, .medium))
                                                    .frame(width: 32, height: 32)
                                                    .bubble(radius: 16, fill: Color.white.opacity(0.88))
                                            }
                                            Spacer()
                                            Button {
                                                viewModel.recenter()
                                                mapPosition = .region(viewModel.region)
                                            } label: {
                                                Image(systemName: "location.fill")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(PawsyTheme.textPrimary)
                                                    .frame(width: 32, height: 32)
                                                    .bubble(radius: 16, fill: Color.white.opacity(0.88))
                                            }
                                            .buttonStyle(PressableBubbleButtonStyle())
                                        }
                                        .padding(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PawsyTheme.horizontalPadding)
                    .padding(.bottom, 118)
                }
            }
            .padding(.top, 8)
        }
        .accessibilityIdentifier("screen.profile")
        .sheet(item: $selectedPet) { pet in
            PetProfileDetailSheet(
                pet: pet,
                isActive: viewModel.activePet?.id == pet.id,
                onSetActive: { viewModel.setActivePet(pet.id) },
                onDelete: { viewModel.deletePet(pet.id) }
            )
                .presentationDetents([.fraction(0.32), .medium])
        }
        .sheet(isPresented: $isAddingPet) {
            PetOnboardingView(mode: .addAnother) { profile in
                viewModel.addPet(profile)
                isAddingPet = false
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
                    .glass(radius: 15)
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .accessibilityIdentifier("profile.back")

            Spacer()

            Text("Profile")
                .font(.pawsy(22, .semibold))
                .foregroundStyle(PawsyTheme.textPrimary)
                .accessibilityIdentifier("title.profile")

            Spacer()

            Button {
                router.openAppSettings()
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .glass(radius: 15)
            }
            .buttonStyle(PressableBubbleButtonStyle())
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }
}

private struct PetProfileDetailSheet: View {
    let pet: PetProfile
    let isActive: Bool
    let onSetActive: () -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 14) {
                Group {
                    if UIImage(named: pet.avatarAsset) != nil {
                        Image(pet.avatarAsset)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Text("🐶")
                            .font(.pawsy(48, .bold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(PawsyTheme.accentGreen.opacity(0.65))
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                Text(pet.name)
                    .font(.pawsy(24, .black))
                    .foregroundStyle(PawsyTheme.textPrimary)

                Text("Healthy and active")
                    .font(.pawsy(14, .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)

                Text("\(pet.species.title) • \(pet.displayBreed)")
                    .font(.pawsy(13, .medium))
                    .foregroundStyle(PawsyTheme.textSecondary)

                HStack(spacing: 10) {
                    if !isActive {
                        Button("Set Active") {
                            onSetActive()
                            dismiss()
                        }
                        .font(.pawsy(14, .bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .bubble(radius: 12, fill: PawsyTheme.accentGreen.opacity(0.75))
                    }

                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                    .font(.pawsy(14, .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .bubble(radius: 12, fill: Color(hex: "#FFD6D9"))
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    let profiles = PetProfilesViewModel()
    return ProfileView(
        viewModel: ProfileViewModel(repository: InMemoryMockRepository(), petProfiles: profiles)
    )
        .environmentObject(profiles)
        .environmentObject(AppRouter())
}
