//
//  ConversationStarters.swift
//  MusicJam
//
//  Service for generating smart conversation starters for musicians
//

import Foundation

// MARK: - Conversation Starter Model

struct ConversationStarter: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let category: StarterCategory

    enum StarterCategory {
        case sharedInstrument
        case sharedGenre
        case location
        case bio
        case experience
        case generic
    }
}

// MARK: - Conversation Starters Service

class ConversationStarters {
    static let shared = ConversationStarters()

    private init() {}

    func generateStarters(currentUser: User, otherUser: User) -> [ConversationStarter] {
        var starters: [ConversationStarter] = []

        // Shared instruments
        let sharedInstruments = Set(currentUser.instruments).intersection(Set(otherUser.instruments))
        if let instrument = sharedInstruments.first {
            starters.append(ConversationStarter(
                text: "I see you also play \(instrument)! How long have you been playing?",
                icon: "guitars.fill",
                category: .sharedInstrument
            ))
        }

        // Shared genres
        let sharedGenres = Set(currentUser.genres).intersection(Set(otherUser.genres))
        if let genre = sharedGenres.first {
            starters.append(ConversationStarter(
                text: "Love that you're into \(genre)! Who are your biggest influences?",
                icon: "music.note.list",
                category: .sharedGenre
            ))
        }

        // Complementary instruments (e.g., drummer looking for guitarist)
        if !sharedInstruments.isEmpty || hasComplementaryInstruments(currentUser: currentUser, otherUser: otherUser) {
            starters.append(ConversationStarter(
                text: "Your instrument lineup would be perfect for a jam! Want to play sometime?",
                icon: "person.2.fill",
                category: .sharedInstrument
            ))
        }

        // Location-based
        if !otherUser.location.isEmpty {
            starters.append(ConversationStarter(
                text: "Are there any good venues or open mics in \(otherUser.location)?",
                icon: "mappin.circle.fill",
                category: .location
            ))
        }

        // Bio-based (if bio has music keywords)
        if !otherUser.bio.isEmpty {
            if otherUser.bio.lowercased().contains("band") {
                starters.append(ConversationStarter(
                    text: "Tell me about your band experience! What kind of projects have you worked on?",
                    icon: "person.3.fill",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("studio") || otherUser.bio.lowercased().contains("recording") {
                starters.append(ConversationStarter(
                    text: "I saw you do studio work! What's your recording setup like?",
                    icon: "waveform",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("gig") || otherUser.bio.lowercased().contains("live") {
                starters.append(ConversationStarter(
                    text: "What's the best gig you've ever played?",
                    icon: "music.mic",
                    category: .bio
                ))
            }
        }

        // Experience-based
        if let experienceLevel = otherUser.experienceLevel, !experienceLevel.isEmpty {
            starters.append(ConversationStarter(
                text: "What's the most valuable lesson you've learned as a musician?",
                icon: "lightbulb.fill",
                category: .experience
            ))
        }

        // Music links
        if !otherUser.musicLinks.isEmpty {
            starters.append(ConversationStarter(
                text: "Just checked out your music samples - really dig your sound!",
                icon: "play.circle.fill",
                category: .bio
            ))
        }

        // Generic music-focused starters
        let genericStarters = [
            ConversationStarter(
                text: "What song are you currently obsessed with learning?",
                icon: "music.note",
                category: .generic
            ),
            ConversationStarter(
                text: "Do you prefer writing originals or playing covers?",
                icon: "pencil.and.outline",
                category: .generic
            ),
            ConversationStarter(
                text: "What's your dream collaboration?",
                icon: "star.fill",
                category: .generic
            ),
            ConversationStarter(
                text: "What gear are you currently GASing for?",
                icon: "amplifier",
                category: .generic
            ),
            ConversationStarter(
                text: "What got you started playing music?",
                icon: "sparkles",
                category: .generic
            ),
            ConversationStarter(
                text: "Any upcoming gigs or projects you're working on?",
                icon: "calendar",
                category: .generic
            ),
            ConversationStarter(
                text: "What's your practice routine like?",
                icon: "clock.fill",
                category: .generic
            )
        ]

        // Add generic starters to fill up to 5 total
        let remainingCount = max(0, 5 - starters.count)
        starters.append(contentsOf: genericStarters.shuffled().prefix(remainingCount))

        return Array(starters.prefix(5))
    }

    // Check if users have complementary instruments for a band
    private func hasComplementaryInstruments(currentUser: User, otherUser: User) -> Bool {
        let bandEssentials = ["vocals", "guitar", "bass", "drums", "keyboard"]
        let currentInstruments = Set(currentUser.instruments.map { $0.lowercased() })
        let otherInstruments = Set(otherUser.instruments.map { $0.lowercased() })

        // Check if together they cover more band roles
        let combinedBandCoverage = currentInstruments.union(otherInstruments).intersection(Set(bandEssentials))
        return combinedBandCoverage.count >= 2
    }
}
