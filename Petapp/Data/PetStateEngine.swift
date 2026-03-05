import Foundation

struct PetStateEngine {
    private let calendar = Calendar.current

    func apply(action: PetAction, to current: PetState, now: Date = Date()) -> PetActionResult {
        guard action != .idle else {
            return PetActionResult(
                state: current,
                message: "Ready to play.",
                isBlocked: false,
                cooldownRemaining: nil,
                changedStatTitles: []
            )
        }

        if let remaining = cooldownRemaining(for: action, in: current, now: now), remaining > 0 {
            return PetActionResult(
                state: current,
                message: "Ready in \(format(remaining))",
                isBlocked: true,
                cooldownRemaining: remaining,
                changedStatTitles: []
            )
        }

        var nextVitals = current.vitals
        var changedStats: [String] = []
        let response: String

        switch action {
        case .feed:
            nextVitals.hunger -= 25
            nextVitals.health += 6
            nextVitals.happiness += 4
            changedStats = ["Happiness", "Health"]
            response = "Yummy. Great meal."
        case .walk:
            nextVitals.energy -= 15
            nextVitals.health += 10
            nextVitals.happiness += 8
            nextVitals.hygiene -= 3
            nextVitals.hygiene -= 1
            changedStats = ["Happiness", "Health", "Hygiene"]
            response = "Great walk. Feeling fresh."
        case .play:
            nextVitals.energy -= 20
            nextVitals.happiness += 14
            nextVitals.health += 3
            changedStats = ["Happiness", "Health"]
            response = "That was fun. More soon."
        case .idle:
            response = "Ready to play."
        }

        var completedActions = current.completedActionsToday
        var dailyBonusAwarded = current.dailyBonusAwarded

        if !calendar.isDate(current.updatedAt, inSameDayAs: now) {
            completedActions.removeAll()
            dailyBonusAwarded = false
        }

        completedActions.insert(action)
        var finalResponse = response

        if completedActions.count == 3 && !dailyBonusAwarded {
            nextVitals.happiness += 5
            changedStats.append("Happiness")
            dailyBonusAwarded = true
            finalResponse = "Perfect care day bonus unlocked."
        }

        nextVitals = clamped(nextVitals)
        var timestamps = current.actionTimestamps
        timestamps.set(now, for: action)
        var nextLog = current.activityLog
        nextLog.append(PetActivityEntry(id: UUID(), action: action, timestamp: now, note: finalResponse))
        if nextLog.count > 200 {
            nextLog.removeFirst(nextLog.count - 200)
        }

        let nextState = PetState(
            vitals: nextVitals,
            mood: mood(for: nextVitals),
            lastAction: action,
            updatedAt: now,
            actionTimestamps: timestamps,
            completedActionsToday: completedActions,
            dailyBonusAwarded: dailyBonusAwarded,
            activityLog: nextLog
        )
        return PetActionResult(
            state: nextState,
            message: finalResponse,
            isBlocked: false,
            cooldownRemaining: nil,
            changedStatTitles: Array(Set(changedStats))
        )
    }

    func initialState() -> PetState {
        PetState(
            vitals: .default,
            mood: mood(for: .default),
            lastAction: .idle,
            updatedAt: Date(),
            actionTimestamps: ActionTimestamps(),
            completedActionsToday: [],
            dailyBonusAwarded: false,
            activityLog: []
        )
    }

    func cooldownRemaining(for action: PetAction, in state: PetState, now: Date = Date()) -> TimeInterval? {
        guard action != .idle,
              let lastTime = state.actionTimestamps.date(for: action) else {
            return nil
        }
        let cooldown = action.cooldownSeconds
        let elapsed = now.timeIntervalSince(lastTime)
        return max(0, cooldown - elapsed)
    }

    private func clamped(_ vitals: PetVitals) -> PetVitals {
        PetVitals(
            happiness: clamp(vitals.happiness),
            health: clamp(vitals.health),
            hygiene: clamp(vitals.hygiene),
            energy: clamp(vitals.energy),
            hunger: clamp(vitals.hunger)
        )
    }

    private func clamp(_ value: Int) -> Int {
        max(0, min(100, value))
    }

    private func mood(for vitals: PetVitals) -> String {
        if vitals.health < 45 { return "Needs care" }
        if vitals.energy < 30 { return "Tired now" }
        if vitals.hunger > 70 { return "Hungry now" }
        if vitals.happiness > 80 { return "Ready to play" }
        return "Calm and comfy"
    }

    private func format(_ remaining: TimeInterval) -> String {
        let totalSeconds = max(0, Int(remaining.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
