//
//  PersonalizedOnboardingManager.swift
//  MusicJam
//
//  Manages personalized onboarding paths based on musician goals and preferences
//  Adapts the onboarding experience to match musician intentions
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on musician goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: OnboardingMusicianGoal?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum OnboardingMusicianGoal: String, Codable, CaseIterable {
        case findBandMembers = "find_band_members"
        case startBand = "start_band"
        case casualJamming = "casual_jamming"
        case studioCollaboration = "studio_collaboration"
        case openToOpportunities = "open_to_opportunities"

        var displayName: String {
            switch self {
            case .findBandMembers: return "Find Band Members"
            case .startBand: return "Start a Band"
            case .casualJamming: return "Casual Jam Sessions"
            case .studioCollaboration: return "Studio Collaboration"
            case .openToOpportunities: return "Open to All Opportunities"
            }
        }

        var icon: String {
            switch self {
            case .findBandMembers: return "person.3.fill"
            case .startBand: return "star.fill"
            case .casualJamming: return "music.note.list"
            case .studioCollaboration: return "waveform"
            case .openToOpportunities: return "sparkles"
            }
        }

        var description: String {
            switch self {
            case .findBandMembers:
                return "Looking for musicians to complete your band lineup"
            case .startBand:
                return "Ready to form a new musical project from scratch"
            case .casualJamming:
                return "Informal sessions to play and have fun"
            case .studioCollaboration:
                return "Recording, producing, and creating together"
            case .openToOpportunities:
                return "Exploring all musical possibilities"
            }
        }

        var color: Color {
            switch self {
            case .findBandMembers: return .orange
            case .startBand: return .purple
            case .casualJamming: return .green
            case .studioCollaboration: return .blue
            case .openToOpportunities: return .pink
            }
        }
    }

    struct OnboardingPath {
        let goal: OnboardingMusicianGoal
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case profileDepth = "profile_depth"
            case photoQuality = "photo_quality"
            case bioOptimization = "bio_optimization"
            case instrumentMatching = "instrument_matching"
            case genreMatching = "genre_matching"
            case locationAccuracy = "location_accuracy"
            case verificationTrust = "verification_trust"
            case audioSamples = "audio_samples"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: OnboardingMusicianGoal) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected musician goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: OnboardingMusicianGoal) -> OnboardingPath {
        switch goal {
        case .findBandMembers:
            return createFindBandMembersPath()
        case .startBand:
            return createStartBandPath()
        case .casualJamming:
            return createCasualJammingPath()
        case .studioCollaboration:
            return createStudioCollaborationPath()
        case .openToOpportunities:
            return createOpenPath()
        }
    }

    private func createFindBandMembersPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findBandMembers,
            steps: [
                OnboardingPathStep(
                    id: "detailed_profile",
                    title: "Create Your Musician Profile",
                    description: "Share your instruments, genres, and musical experience",
                    importance: .critical,
                    tips: [
                        "List all instruments you play with skill levels",
                        "Add performance or practice photos/videos",
                        "Share your musical influences and style"
                    ]
                ),
                OnboardingPathStep(
                    id: "audio_samples",
                    title: "Add Audio Samples",
                    description: "Let musicians hear what you sound like",
                    importance: .critical,
                    tips: [
                        "Link to SoundCloud, YouTube, or Spotify",
                        "Audio samples get 3x more jam requests",
                        "Quality recordings show your skill level"
                    ]
                ),
                OnboardingPathStep(
                    id: "band_needs",
                    title: "Specify What You Need",
                    description: "Tell us what instruments/roles you're looking for",
                    importance: .recommended,
                    tips: [
                        "Be specific about the instruments needed",
                        "Describe your band's style and commitment level",
                        "Mention any requirements (own equipment, transport)"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .audioSamples, .instrumentMatching, .genreMatching],
            recommendedFeatures: ["Audio Samples", "Jam Sessions", "Band Profiles"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "jam_sessions"]
        )
    }

    private func createStartBandPath() -> OnboardingPath {
        OnboardingPath(
            goal: .startBand,
            steps: [
                OnboardingPathStep(
                    id: "musician_profile",
                    title: "Showcase Your Talents",
                    description: "Share your instruments and musical vision",
                    importance: .critical,
                    tips: [
                        "Add photos of you performing or with your gear",
                        "Describe your musical vision and goals",
                        "Show different aspects of your musicianship"
                    ]
                ),
                OnboardingPathStep(
                    id: "genres_style",
                    title: "Define Your Sound",
                    description: "What kind of band do you want to create?",
                    importance: .critical,
                    tips: [
                        "Select genres you want to play",
                        "Mention your influences and inspirations",
                        "Be clear about original vs. cover music"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .genreMatching, .audioSamples, .locationAccuracy],
            recommendedFeatures: ["Band Creation", "Nearby Musicians", "Genre Filters"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "band_creation"]
        )
    }

    private func createCasualJammingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .casualJamming,
            steps: [
                OnboardingPathStep(
                    id: "jam_profile",
                    title: "Create a Jam-Ready Profile",
                    description: "Show what you bring to a jam session",
                    importance: .critical,
                    tips: [
                        "List your main instruments",
                        "Share genres you enjoy jamming",
                        "Be open and approachable"
                    ]
                ),
                OnboardingPathStep(
                    id: "availability",
                    title: "Set Your Availability",
                    description: "When and where can you jam?",
                    importance: .recommended,
                    tips: [
                        "Add your location for local connections",
                        "Mention if you have a practice space",
                        "Be flexible about styles and setups"
                    ]
                )
            ],
            focusAreas: [.instrumentMatching, .genreMatching, .locationAccuracy],
            recommendedFeatures: ["Quick Match", "Nearby Musicians", "Jam Sessions"],
            tutorialPriority: ["matching", "messaging", "profile_quality", "jam_scheduling"]
        )
    }

    private func createStudioCollaborationPath() -> OnboardingPath {
        OnboardingPath(
            goal: .studioCollaboration,
            steps: [
                OnboardingPathStep(
                    id: "producer_profile",
                    title: "Build Your Studio Profile",
                    description: "Highlight your production skills and equipment",
                    importance: .critical,
                    tips: [
                        "Share your production/engineering background",
                        "List your DAW and equipment",
                        "Link to your best productions"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_work",
                    title: "Showcase Your Work",
                    description: "Let collaborators hear your productions",
                    importance: .critical,
                    tips: [
                        "Link to streaming platforms or portfolio",
                        "Verified producers get more collaboration requests",
                        "Share your credits and experience"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .audioSamples, .verificationTrust],
            recommendedFeatures: ["Studio Profiles", "Collaboration Requests", "Portfolio Links"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "studio_booking"]
        )
    }

    private func createOpenPath() -> OnboardingPath {
        OnboardingPath(
            goal: .openToOpportunities,
            steps: [
                OnboardingPathStep(
                    id: "basic_profile",
                    title: "Create Your Music Profile",
                    description: "Start with the basics and explore from there",
                    importance: .critical,
                    tips: [
                        "Add photos of you with your instrument",
                        "Write about your musical journey",
                        "Select genres and instruments you play"
                    ]
                ),
                OnboardingPathStep(
                    id: "explore",
                    title: "Start Discovering Musicians",
                    description: "See who's making music in your area",
                    importance: .recommended,
                    tips: [
                        "Browse local musicians and bands",
                        "You can always update your preferences",
                        "Be open to unexpected collaborations"
                    ]
                )
            ],
            focusAreas: [.photoQuality, .bioOptimization, .instrumentMatching, .genreMatching],
            recommendedFeatures: ["Discovery", "Filters", "Profile Insights"],
            tutorialPriority: ["welcome", "matching", "messaging", "profile_quality"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "scrolling", "matching", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(OnboardingMusicianGoal.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.OnboardingMusicianGoal) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's Your Musical Goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us find the right musicians for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.OnboardingMusicianGoal.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.orange, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.05), Color.purple.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.OnboardingMusicianGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
