//
//  CollaborationTipsView.swift
//  MusicJam
//
//  Safety tips and resources for musical collaborations
//

import SwiftUI

struct SafeDatingTipsView: View {
    @State private var selectedCategory: TipCategory = .beforeMeeting

    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker

            // Tips List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SafetyTip.tips(for: selectedCategory)) { tip in
                        SafetyTipCard(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Collaboration Tips")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TipCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: TipCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.title)
                    .font(.caption.bold())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.orange, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Safety Tip Card

struct SafetyTipCard: View {
    let tip: SafetyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tip.priority.color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: tip.icon)
                        .font(.title3)
                        .foregroundColor(tip.priority.color)
                }

                Text(tip.title)
                    .font(.headline)

                Spacer()

                if tip.priority == .critical {
                    Text("IMPORTANT")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action items if present
            if !tip.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tip.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(item)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Models

enum TipCategory: CaseIterable {
    case beforeMeeting
    case firstJam
    case ongoingSafety
    case redFlags
    case resources

    var title: String {
        switch self {
        case .beforeMeeting: return "Before"
        case .firstJam: return "First Jam"
        case .ongoingSafety: return "Ongoing"
        case .redFlags: return "Red Flags"
        case .resources: return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .beforeMeeting: return "calendar.badge.clock"
        case .firstJam: return "guitars.fill"
        case .ongoingSafety: return "shield.checkered"
        case .redFlags: return "exclamationmark.triangle.fill"
        case .resources: return "link"
        }
    }
}

enum TipPriority {
    case critical
    case important
    case helpful

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .helpful: return .blue
        }
    }
}

struct SafetyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: TipPriority
    let actionItems: [String]

    static func tips(for category: TipCategory) -> [SafetyTip] {
        switch category {
        case .beforeMeeting:
            return [
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Chat First",
                    description: "Message for a bit before meeting to jam. Get to know their musical style and goals.",
                    priority: .important,
                    actionItems: [
                        "Have several conversations",
                        "Share music samples",
                        "Discuss musical influences"
                    ]
                ),
                SafetyTip(
                    icon: "waveform",
                    title: "Listen to Their Work",
                    description: "Check out their SoundCloud, YouTube, or Spotify to verify their skill level and style compatibility.",
                    priority: .important,
                    actionItems: [
                        "Listen to their samples",
                        "Check their social profiles",
                        "Verify genre compatibility"
                    ]
                ),
                SafetyTip(
                    icon: "person.2.fill",
                    title: "Share Your Plans",
                    description: "Tell a friend or bandmate where you're going and who you're meeting for the jam session.",
                    priority: .critical,
                    actionItems: [
                        "Share jam location and time",
                        "Send musician's profile info",
                        "Set up check-in times"
                    ]
                ),
                SafetyTip(
                    icon: "video.fill",
                    title: "Video Chat First",
                    description: "A quick video call helps verify they're real and lets you discuss the jam beforehand.",
                    priority: .helpful,
                    actionItems: [
                        "Suggest a quick video call",
                        "Discuss what songs to play",
                        "Gauge your comfort level"
                    ]
                )
            ]

        case .firstJam:
            return [
                SafetyTip(
                    icon: "building.2.fill",
                    title: "Meet in a Public Space",
                    description: "Choose a rehearsal studio or music shop for your first jam. Avoid private residences until you know them.",
                    priority: .critical,
                    actionItems: [
                        "Book a rehearsal room",
                        "Choose a music cafe or shop",
                        "Avoid isolated locations"
                    ]
                ),
                SafetyTip(
                    icon: "car.fill",
                    title: "Arrange Your Own Transport",
                    description: "Drive yourself or use rideshare. Keep your address private until you've built trust.",
                    priority: .critical,
                    actionItems: [
                        "Drive yourself",
                        "Use Uber/Lyft",
                        "Keep your address private"
                    ]
                ),
                SafetyTip(
                    icon: "guitars.fill",
                    title: "Bring Your Own Gear",
                    description: "Bring your own instrument and equipment. This ensures you have what you need and can leave anytime.",
                    priority: .important,
                    actionItems: [
                        "Bring your instrument",
                        "Bring essential cables/picks",
                        "Have backup equipment"
                    ]
                ),
                SafetyTip(
                    icon: "iphone",
                    title: "Keep Your Phone Charged",
                    description: "Ensure your phone is charged so you can call for help or a ride if needed.",
                    priority: .important,
                    actionItems: [
                        "Charge phone before leaving",
                        "Bring a portable charger",
                        "Keep emergency numbers handy"
                    ]
                )
            ]

        case .ongoingSafety:
            return [
                SafetyTip(
                    icon: "ear",
                    title: "Trust Your Instincts",
                    description: "If something feels off about the collaboration, trust your gut. You can always find other musicians.",
                    priority: .critical,
                    actionItems: [
                        "Listen to your gut",
                        "Don't ignore red flags",
                        "Leave if uncomfortable"
                    ]
                ),
                SafetyTip(
                    icon: "lock.shield.fill",
                    title: "Protect Your Music",
                    description: "Be careful about sharing unreleased original music until you've established trust and clear agreements.",
                    priority: .important,
                    actionItems: [
                        "Discuss ownership upfront",
                        "Get agreements in writing",
                        "Protect your original work"
                    ]
                ),
                SafetyTip(
                    icon: "doc.text.fill",
                    title: "Clear Agreements",
                    description: "For serious collaborations, discuss and document expectations about credits, royalties, and ownership.",
                    priority: .helpful,
                    actionItems: [
                        "Discuss roles and credits",
                        "Document agreements",
                        "Be clear about expectations"
                    ]
                ),
                SafetyTip(
                    icon: "clock.fill",
                    title: "Build Trust Gradually",
                    description: "Take your time before sharing personal info, expensive gear, or your home studio access.",
                    priority: .helpful,
                    actionItems: [
                        "Set your own pace",
                        "Build trust over time",
                        "Protect valuable equipment"
                    ]
                )
            ]

        case .redFlags:
            return [
                SafetyTip(
                    icon: "exclamationmark.triangle.fill",
                    title: "Pressure Tactics",
                    description: "Be wary of musicians who pressure you to commit quickly, share personal info, or invest money.",
                    priority: .critical,
                    actionItems: [
                        "Don't rush decisions",
                        "Set clear boundaries",
                        "Walk away if pressured"
                    ]
                ),
                SafetyTip(
                    icon: "eye.slash.fill",
                    title: "No Samples or Portfolio",
                    description: "Be cautious of musicians who won't share any recordings or proof of their abilities.",
                    priority: .important,
                    actionItems: [
                        "Ask for samples",
                        "Check online presence",
                        "Request references"
                    ]
                ),
                SafetyTip(
                    icon: "dollarsign.circle.fill",
                    title: "Asks for Money Upfront",
                    description: "Legitimate collaborations don't require you to pay money upfront. Be very wary of these requests.",
                    priority: .critical,
                    actionItems: [
                        "Never pay upfront",
                        "Report suspicious requests",
                        "Block the user"
                    ]
                ),
                SafetyTip(
                    icon: "person.fill.questionmark",
                    title: "Vague About Experience",
                    description: "Be cautious if they're evasive about their musical background or band history.",
                    priority: .important,
                    actionItems: [
                        "Ask specific questions",
                        "Verify their claims",
                        "Trust your judgment"
                    ]
                ),
                SafetyTip(
                    icon: "photo.on.rectangle.angled",
                    title: "Won't Video Chat",
                    description: "If they consistently refuse video calls, they may be hiding something about their identity.",
                    priority: .important,
                    actionItems: [
                        "Insist on video chat",
                        "Be suspicious of excuses",
                        "Consider ending contact"
                    ]
                )
            ]

        case .resources:
            return [
                SafetyTip(
                    icon: "phone.fill",
                    title: "Emergency Services",
                    description: "In immediate danger, always call 911 (or your local emergency number).",
                    priority: .critical,
                    actionItems: [
                        "911 for emergencies",
                        "Know local police non-emergency",
                        "Save these in your phone"
                    ]
                ),
                SafetyTip(
                    icon: "music.note.house.fill",
                    title: "Musicians Union",
                    description: "Your local musicians union can provide resources and support for professional collaborations.",
                    priority: .helpful,
                    actionItems: [
                        "Join local musician groups",
                        "Network with established musicians",
                        "Seek advice from peers"
                    ]
                ),
                SafetyTip(
                    icon: "doc.text.magnifyingglass",
                    title: "Contract Templates",
                    description: "Use proper contracts for serious collaborations to protect your work and rights.",
                    priority: .helpful,
                    actionItems: [
                        "Research split sheets",
                        "Learn about music copyright",
                        "Consult entertainment lawyers"
                    ]
                ),
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Crisis Text Line",
                    description: "Text HOME to 741741 for free, 24/7 crisis support via text message.",
                    priority: .helpful,
                    actionItems: [
                        "Text HOME to 741741",
                        "Available 24/7",
                        "All issues welcome"
                    ]
                ),
                SafetyTip(
                    icon: "network",
                    title: "Online Resources",
                    description: "Visit these websites for more information on music collaboration and safety.",
                    priority: .helpful,
                    actionItems: [
                        "musicianswithoutborders.org",
                        "ascap.com (licensing info)",
                        "bmi.com (rights info)"
                    ]
                )
            ]
        }
    }
}

#Preview {
    NavigationStack {
        SafeDatingTipsView()
    }
}
