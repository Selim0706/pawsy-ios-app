import SwiftUI

enum PetOnboardingMode {
    case firstRun
    case addAnother
}

struct PetOnboardingView: View {
    let mode: PetOnboardingMode
    let onSave: (PetProfile) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft = PetProfile.draftDefault()
    @State private var birthDateEnabled = false

    @State private var currentStep: FirstRunStep = .welcome

    @State private var showSpeciesSheet = false
    @State private var showBreedSheet = false
    @State private var showSexSheet = false
    @State private var showStyleSheet = false
    @State private var showAccessorySheet = false
    @State private var showBirthDateSheet = false

    private enum FirstRunStep: Int, CaseIterable {
        case welcome
        case auth
        case intro
        case basic
        case petType
        case medical
        case review
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if mode == .firstRun {
                    firstRunWizard
                } else {
                    addPetForm
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
        .interactiveDismissDisabled(mode == .firstRun)
        .sheet(isPresented: $showSpeciesSheet) {
            SelectionListSheet(
                title: "Select Animal",
                options: PetSpecies.allCases.map(\.title),
                selected: draft.species.title
            ) { picked in
                guard let species = PetSpecies.allCases.first(where: { $0.title == picked }) else { return }
                draft.species = species
                draft.breed = ""
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showBreedSheet) {
            SelectionListSheet(
                title: "Select Breed",
                options: PetCatalog.breeds(for: draft.species),
                selected: draft.breed
            ) { picked in
                draft.breed = picked
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSexSheet) {
            SelectionListSheet(
                title: "Select Sex",
                options: PetSex.allCases.map(\.title),
                selected: draft.sex.title
            ) { picked in
                guard let sex = PetSex.allCases.first(where: { $0.title == picked }) else { return }
                draft.sex = sex
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showStyleSheet) {
            SelectionListSheet(
                title: "Pet Style",
                options: PetStyle.allCases.map { "\($0.emoji) \($0.title)" },
                selected: "\(draft.style.emoji) \(draft.style.title)"
            ) { picked in
                if let style = PetStyle.allCases.first(where: { picked.contains($0.title) }) {
                    draft.style = style
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAccessorySheet) {
            SelectionListSheet(
                title: "Accessory",
                options: PetAccessory.allCases.map(\.title),
                selected: draft.accessory.title
            ) { picked in
                if let accessory = PetAccessory.allCases.first(where: { $0.title == picked }) {
                    draft.accessory = accessory
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showBirthDateSheet) {
            DateSelectionSheet(
                title: "Birth Date",
                date: Binding(
                    get: { draft.birthDate ?? .now },
                    set: { draft.birthDate = $0 }
                )
            )
            .presentationDetents([.large])
        }
    }

    private var firstRunWizard: some View {
        VStack(spacing: 16) {
            progressBar
                .padding(.horizontal, PawsyTheme.horizontalPadding)
                .padding(.top, 10)

            Group {
                switch currentStep {
                case .welcome:
                    welcomeStep
                case .auth:
                    authStep
                case .intro:
                    introStep
                case .basic:
                    basicStep
                case .petType:
                    speciesStep
                case .medical:
                    medicalStep
                case .review:
                    reviewStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomActions
                .padding(.horizontal, PawsyTheme.horizontalPadding)
                .padding(.bottom, 16)
        }
    }

    private var addPetForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    PawsyWordmark(fontSize: 20, iconSize: 24)
                    Spacer()
                }

                Text("Add New Pet")
                    .font(.pawsy(30, .black))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                basicStep
                speciesStep
                medicalStep

                Button {
                    saveAndClose()
                } label: {
                    Text("Save Pet")
                        .font(.pawsy(17, .bold))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .bubbleStrong(radius: 18, fill: PawsyTheme.accentGreen.opacity(0.82))
                }
                .buttonStyle(PressableBubbleButtonStyle())
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.55)
            }
            .padding(PawsyTheme.horizontalPadding)
            .padding(.bottom, 24)
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if mode == .addAnother {
                Button("Cancel") { dismiss() }
            } else {
                Button("Skip") { skipFlow() }
                    .font(.pawsy(14, .semibold))
            }
        }
    }

    private var progressBar: some View {
        let total = Double(FirstRunStep.allCases.count)
        let current = Double(currentStep.rawValue + 1)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(Int(current))/\(Int(total))")
                    .font(.pawsy(12, .semibold))
                    .foregroundStyle(PawsyTheme.textSecondary)
                Spacer()
            }
            ProgressView(value: current / total)
                .tint(PawsyTheme.accentEmerald)
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 12)

            ZStack {
                Circle().fill(Color.white.opacity(0.25)).frame(width: 210, height: 210)
                Circle().fill(Color.white.opacity(0.20)).frame(width: 160, height: 160)
                Text("🐾")
                    .font(.system(size: 94))
            }

            Text("Welcome to Pawsy")
                .font(.pawsy(34, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            Text("Track every pet with a gentle, smart daily flow.\nLet's set up your first pet in 2 minutes.")
                .font(.pawsy(15, .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(PawsyTheme.textSecondary)
                .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var authStep: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 20)

            Text("Sign In (Optional)")
                .font(.pawsy(30, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            Text("You can connect an account now or skip and continue offline.")
                .font(.pawsy(14, .semibold))
                .foregroundStyle(PawsyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Button {
                nextStep()
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                        .font(.pawsy(16, .bold))
                }
                .foregroundStyle(PawsyTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .bubble(radius: 18, fill: Color.white.opacity(0.80))
            }
            .buttonStyle(PressableBubbleButtonStyle())

            Button {
                nextStep()
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text("Continue with Google")
                        .font(.pawsy(16, .bold))
                }
                .foregroundStyle(PawsyTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .bubble(radius: 18, fill: Color.white.opacity(0.80))
            }
            .buttonStyle(PressableBubbleButtonStyle())

            Spacer()
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var introStep: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 10)
            Text("Let's Register Your Pet")
                .font(.pawsy(31, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            Text("Fill profile step-by-step. You can skip any part and edit later in Profile.")
                .font(.pawsy(14, .semibold))
                .foregroundStyle(PawsyTheme.textSecondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 10) {
                infoRow(icon: "heart.fill", text: "Health and mood tracking")
                infoRow(icon: "calendar", text: "Vaccination and visit reminders")
                infoRow(icon: "message.fill", text: "AI chat per active pet")
            }
            .padding(14)
            .bubble(radius: 22, fill: Color.white.opacity(0.65))

            Spacer()
        }
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var basicStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Basics")
                .font(.pawsy(24, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            Text("Name")
                .font(.pawsy(13, .semibold))
                .foregroundStyle(PawsyTheme.textSecondary)

            TextField("Pet name", text: $draft.name)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .bubble(radius: 14, fill: Color.white.opacity(0.86))

            selectionRow(title: "Style", value: "\(draft.style.emoji) \(draft.style.title)") {
                showStyleSheet = true
            }

            selectionRow(title: "Accessory", value: draft.accessory.title) {
                showAccessorySheet = true
            }
        }
        .padding(16)
        .bubble(radius: 24, fill: Color.white.opacity(0.58))
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var speciesStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Animal & Breed")
                .font(.pawsy(24, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            selectionRow(title: "Animal", value: draft.species.title) {
                showSpeciesSheet = true
            }

            selectionRow(
                title: "Breed",
                value: draft.breed.isEmpty ? "Select breed" : draft.breed,
                valueColor: draft.breed.isEmpty ? PawsyTheme.textSecondary : PawsyTheme.textPrimary
            ) {
                if PetCatalog.breeds(for: draft.species).isEmpty {
                    draft.breed = ""
                } else {
                    showBreedSheet = true
                }
            }

            selectionRow(title: "Sex", value: draft.sex.title) {
                showSexSheet = true
            }

            VStack(alignment: .leading, spacing: 8) {
                BubbleToggleRow(
                    title: "Known birth date",
                    subtitle: birthDateEnabled ? "Birth date is included in this pet profile" : "You can skip this and add it later",
                    isOn: $birthDateEnabled
                )
                if birthDateEnabled {
                    BubbleSelectionRow(
                        title: "Birth date",
                        value: (draft.birthDate ?? .now).formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar"
                    ) {
                        showBirthDateSheet = true
                    }
                }
            }
        }
        .padding(16)
        .bubble(radius: 24, fill: Color.white.opacity(0.58))
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var medicalStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medical Notes")
                .font(.pawsy(24, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            medicalInput("Vaccinations", text: $draft.medical.vaccinations)
            medicalInput("Diseases", text: $draft.medical.diseases)
            medicalInput("Operations", text: $draft.medical.operations)
            medicalInput("Allergies", text: $draft.medical.allergies)
        }
        .padding(16)
        .bubble(radius: 24, fill: Color.white.opacity(0.58))
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.pawsy(24, .black))
                .foregroundStyle(PawsyTheme.textPrimary)

            summaryRow("Name", value: draft.name.isEmpty ? "Not set" : draft.name)
            summaryRow("Animal", value: draft.species.title)
            summaryRow("Breed", value: draft.breed.isEmpty ? "Not set" : draft.breed)
            summaryRow("Sex", value: draft.sex.title)
            summaryRow("Birth date", value: birthDateEnabled && draft.birthDate != nil ? (draft.birthDate?.formatted(date: .abbreviated, time: .omitted) ?? "") : "Not set")
        }
        .padding(16)
        .bubble(radius: 24, fill: Color.white.opacity(0.58))
        .padding(.horizontal, PawsyTheme.horizontalPadding)
    }

    private var bottomActions: some View {
        HStack(spacing: 10) {
            if currentStep.rawValue > 0 {
                Button {
                    previousStep()
                } label: {
                    Text("Back")
                        .font(.pawsy(15, .bold))
                        .foregroundStyle(PawsyTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .bubble(radius: 14, fill: Color.white.opacity(0.72))
                }
                .buttonStyle(PressableBubbleButtonStyle())
            }

            Button {
                advanceOrFinish()
            } label: {
                Text(currentStep == .review ? "Finish" : "Next")
                    .font(.pawsy(15, .bold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .bubbleStrong(radius: 14, fill: PawsyTheme.accentGreen.opacity(0.82))
            }
            .buttonStyle(PressableBubbleButtonStyle())
            .disabled(currentStep == .basic && draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(currentStep == .basic && draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
        }
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveAndClose() {
        var profile = draft
        profile.name = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if profile.name.isEmpty {
            profile.name = "My Pet"
        }
        profile.birthDate = birthDateEnabled ? profile.birthDate : nil
        profile.avatarAsset = defaultAvatar(for: profile.species)
        profile.createdAt = Date()
        onSave(profile)
        if mode == .addAnother { dismiss() }
    }

    private func skipFlow() {
        switch mode {
        case .firstRun:
            onSave(defaultQuickPet())
        case .addAnother:
            dismiss()
        }
    }

    private func defaultQuickPet() -> PetProfile {
        PetProfile(
            id: UUID(),
            name: "My Pet",
            species: .dog,
            breed: "Mixed",
            sex: .unknown,
            birthDate: nil,
            style: .shiba,
            accessory: .greenCollar,
            avatarAsset: "pet_shiba",
            medical: .empty,
            createdAt: Date()
        )
    }

    private func nextStep() {
        guard let next = FirstRunStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            currentStep = next
        }
    }

    private func previousStep() {
        guard let prev = FirstRunStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            currentStep = prev
        }
    }

    private func advanceOrFinish() {
        if currentStep == .review {
            saveAndClose()
        } else {
            nextStep()
        }
    }

    private func defaultAvatar(for species: PetSpecies) -> String {
        switch species {
        case .cat: return "pet_cat"
        case .dog: return "pet_shiba"
        case .bird, .parrot: return "pet_bird"
        case .rabbit: return "pet_rabbit"
        case .hamster, .guineaPig, .ferret, .chinchilla, .hedgehog: return "pet_hamster"
        case .turtle, .fish, .horse, .pig, .goat, .sheep, .cow, .other: return "pet_shiba"
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(PawsyTheme.textPrimary)
                .frame(width: 30, height: 30)
                .bubble(radius: 10, fill: Color.white.opacity(0.84))
            Text(text)
                .font(.pawsy(14, .semibold))
                .foregroundStyle(PawsyTheme.textPrimary)
            Spacer()
        }
    }

    private func selectionRow(title: String, value: String, valueColor: Color = PawsyTheme.textPrimary, action: @escaping () -> Void) -> some View {
        BubbleSelectionRow(title: title, value: value, valueColor: valueColor, action: action)
    }

    private func medicalInput(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.pawsy(12, .semibold))
                .foregroundStyle(PawsyTheme.textSecondary)
            TextField("Optional", text: text)
                .font(.pawsy(14, .medium))
                .foregroundStyle(PawsyTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .bubble(radius: 14, fill: Color.white.opacity(0.80))
        }
    }

    private func summaryRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.pawsy(13, .semibold))
                .foregroundStyle(PawsyTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.pawsy(14, .bold))
                .foregroundStyle(PawsyTheme.textPrimary)
        }
        .padding(.vertical, 2)
    }
}
