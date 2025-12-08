//
//  FilterModels.swift
//  MusicJam
//
//  Data models for advanced search and filtering for musicians
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Search Filter

struct SearchFilter: Codable, Equatable {

    // MARK: - Location
    var distanceRadius: Int = 50 // miles (1-100)
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true

    // MARK: - Demographics
    var ageRange: AgeRange = AgeRange(min: 18, max: 99)
    var heightRange: HeightRange? // Optional, nil = any height
    var gender: GenderFilter = .all
    var showMe: ShowMeFilter = .everyone

    // MARK: - Background
    var educationLevels: [EducationLevel] = []
    var ethnicities: [Ethnicity] = []
    var religions: [Religion] = []
    var languages: [Language] = []

    // MARK: - Lifestyle
    var smoking: LifestyleFilter = .any
    var drinking: LifestyleFilter = .any
    var pets: PetPreference = .any
    var hasChildren: LifestyleFilter = .any
    var wantsChildren: LifestyleFilter = .any
    var exercise: ExerciseFrequency = .any
    var diet: DietPreference = .any

    // MARK: - Musical Collaboration
    var musicianGoals: [MusicianGoal] = []
    var lookingForInstruments: [Instrument] = []
    var genres: [MusicGenre] = []
    var experienceLevel: ExperienceLevel = .any
    var commitmentLevel: CommitmentLevel = .any
    var hasOwnEquipment: LifestyleFilter = .any
    var hasPracticeSpace: LifestyleFilter = .any

    // MARK: - Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = true
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days

    // MARK: - Advanced
    var zodiacSigns: [ZodiacSign] = []
    var politicalViews: [PoliticalView] = []
    var occupations: [String] = []

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 50 &&
               ageRange.min == 18 &&
               ageRange.max == 99 &&
               heightRange == nil &&
               educationLevels.isEmpty &&
               ethnicities.isEmpty &&
               religions.isEmpty &&
               smoking == .any &&
               drinking == .any &&
               pets == .any &&
               musicianGoals.isEmpty &&
               lookingForInstruments.isEmpty &&
               genres.isEmpty &&
               experienceLevel == .any &&
               commitmentLevel == .any &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 50 { count += 1 }
        if ageRange.min != 18 || ageRange.max != 99 { count += 1 }
        if heightRange != nil { count += 1 }
        if !educationLevels.isEmpty { count += 1 }
        if !ethnicities.isEmpty { count += 1 }
        if !religions.isEmpty { count += 1 }
        if smoking != .any { count += 1 }
        if drinking != .any { count += 1 }
        if pets != .any { count += 1 }
        if hasChildren != .any { count += 1 }
        if wantsChildren != .any { count += 1 }
        if !musicianGoals.isEmpty { count += 1 }
        if !lookingForInstruments.isEmpty { count += 1 }
        if !genres.isEmpty { count += 1 }
        if experienceLevel != .any { count += 1 }
        if commitmentLevel != .any { count += 1 }
        if hasOwnEquipment != .any { count += 1 }
        if hasPracticeSpace != .any { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Age Range

struct AgeRange: Codable, Equatable {
    var min: Int // 18-99
    var max: Int // 18-99

    init(min: Int = 18, max: Int = 99) {
        self.min = Swift.max(18, Swift.min(99, min))
        self.max = Swift.max(18, Swift.min(99, max))
    }

    func contains(_ age: Int) -> Bool {
        return age >= min && age <= max
    }
}

// MARK: - Height Range

struct HeightRange: Codable, Equatable {
    var minInches: Int // 48-96 inches (4'0" - 8'0")
    var maxInches: Int

    init(minInches: Int = 48, maxInches: Int = 96) {
        self.minInches = Swift.max(48, Swift.min(96, minInches))
        self.maxInches = Swift.max(48, Swift.min(96, maxInches))
    }

    func contains(_ heightInches: Int) -> Bool {
        return heightInches >= minInches && heightInches <= maxInches
    }

    // Helper: Convert inches to feet/inches display
    static func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

// MARK: - Gender Filter

enum GenderFilter: String, Codable, CaseIterable {
    case all = "all"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .all: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Show Me Filter

enum ShowMeFilter: String, Codable, CaseIterable {
    case everyone = "everyone"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .everyone: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Education Level

enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "high_school"
    case someCollege = "some_college"
    case bachelors = "bachelors"
    case masters = "masters"
    case doctorate = "doctorate"
    case tradeSchool = "trade_school"

    var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .someCollege: return "Some College"
        case .bachelors: return "Bachelor's Degree"
        case .masters: return "Master's Degree"
        case .doctorate: return "Doctorate"
        case .tradeSchool: return "Trade School"
        }
    }

    var icon: String {
        switch self {
        case .highSchool: return "building.2"
        case .someCollege: return "book"
        case .bachelors: return "graduationcap"
        case .masters: return "graduationcap.fill"
        case .doctorate: return "star.fill"
        case .tradeSchool: return "hammer"
        }
    }
}

// MARK: - Ethnicity

enum Ethnicity: String, Codable, CaseIterable {
    case asian = "asian"
    case black = "black"
    case hispanic = "hispanic"
    case middleEastern = "middle_eastern"
    case nativeAmerican = "native_american"
    case pacificIslander = "pacific_islander"
    case white = "white"
    case mixed = "mixed"
    case other = "other"

    var displayName: String {
        switch self {
        case .asian: return "Asian"
        case .black: return "Black / African"
        case .hispanic: return "Hispanic / Latino"
        case .middleEastern: return "Middle Eastern"
        case .nativeAmerican: return "Native American"
        case .pacificIslander: return "Pacific Islander"
        case .white: return "White / Caucasian"
        case .mixed: return "Mixed"
        case .other: return "Other"
        }
    }
}

// MARK: - Religion

enum Religion: String, Codable, CaseIterable {
    case agnostic = "agnostic"
    case atheist = "atheist"
    case buddhist = "buddhist"
    case catholic = "catholic"
    case christian = "christian"
    case hindu = "hindu"
    case jewish = "jewish"
    case muslim = "muslim"
    case spiritual = "spiritual"
    case other = "other"

    var displayName: String {
        switch self {
        case .agnostic: return "Agnostic"
        case .atheist: return "Atheist"
        case .buddhist: return "Buddhist"
        case .catholic: return "Catholic"
        case .christian: return "Christian"
        case .hindu: return "Hindu"
        case .jewish: return "Jewish"
        case .muslim: return "Muslim"
        case .spiritual: return "Spiritual"
        case .other: return "Other"
        }
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        }
    }
}

// MARK: - Lifestyle Filter

enum LifestyleFilter: String, Codable, CaseIterable {
    case any = "any"
    case yes = "yes"
    case no = "no"
    case sometimes = "sometimes"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .yes: return "Yes"
        case .no: return "No"
        case .sometimes: return "Sometimes"
        }
    }
}

// MARK: - Pet Preference

enum PetPreference: String, Codable, CaseIterable {
    case any = "any"
    case hasDogs = "has_dogs"
    case hasCats = "has_cats"
    case hasPets = "has_pets"
    case noPets = "no_pets"
    case allergicToPets = "allergic"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .hasDogs: return "Has Dog(s)"
        case .hasCats: return "Has Cat(s)"
        case .hasPets: return "Has Pets"
        case .noPets: return "No Pets"
        case .allergicToPets: return "Allergic to Pets"
        }
    }

    var icon: String {
        switch self {
        case .any: return "pawprint"
        case .hasDogs: return "dog"
        case .hasCats: return "cat"
        case .hasPets: return "pawprint.fill"
        case .noPets: return "nosign"
        case .allergicToPets: return "bandage"
        }
    }
}

// MARK: - Exercise Frequency

enum ExerciseFrequency: String, Codable, CaseIterable {
    case any = "any"
    case daily = "daily"
    case often = "often"
    case sometimes = "sometimes"
    case rarely = "rarely"
    case never = "never"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .daily: return "Daily"
        case .often: return "Often (3-5x/week)"
        case .sometimes: return "Sometimes (1-2x/week)"
        case .rarely: return "Rarely"
        case .never: return "Never"
        }
    }
}

// MARK: - Diet Preference

enum DietPreference: String, Codable, CaseIterable {
    case any = "any"
    case vegan = "vegan"
    case vegetarian = "vegetarian"
    case pescatarian = "pescatarian"
    case kosher = "kosher"
    case halal = "halal"
    case glutenFree = "gluten_free"
    case omnivore = "omnivore"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .pescatarian: return "Pescatarian"
        case .kosher: return "Kosher"
        case .halal: return "Halal"
        case .glutenFree: return "Gluten-Free"
        case .omnivore: return "Omnivore"
        }
    }
}

// MARK: - Musician Goal

enum MusicianGoal: String, Codable, CaseIterable {
    case findBandMembers = "find_band_members"
    case startBand = "start_band"
    case joinBand = "join_band"
    case casualJamSessions = "casual_jam_sessions"
    case studioCollaboration = "studio_collaboration"
    case songwritingPartner = "songwriting_partner"
    case producerSearch = "producer_search"
    case sessionMusician = "session_musician"
    case openMicBuddy = "open_mic_buddy"
    case musicLessons = "music_lessons"
    case coverBand = "cover_band"

    var displayName: String {
        switch self {
        case .findBandMembers: return "Find Band Members"
        case .startBand: return "Start a New Band"
        case .joinBand: return "Join an Existing Band"
        case .casualJamSessions: return "Casual Jam Sessions"
        case .studioCollaboration: return "Studio Collaboration"
        case .songwritingPartner: return "Songwriting Partner"
        case .producerSearch: return "Looking for a Producer"
        case .sessionMusician: return "Session Musician Work"
        case .openMicBuddy: return "Open Mic Buddy"
        case .musicLessons: return "Music Lessons/Teaching"
        case .coverBand: return "Cover Band"
        }
    }

    var icon: String {
        switch self {
        case .findBandMembers: return "person.3.fill"
        case .startBand: return "star.fill"
        case .joinBand: return "person.badge.plus"
        case .casualJamSessions: return "music.note.list"
        case .studioCollaboration: return "waveform"
        case .songwritingPartner: return "pencil.and.outline"
        case .producerSearch: return "slider.horizontal.3"
        case .sessionMusician: return "music.quarternote.3"
        case .openMicBuddy: return "mic.fill"
        case .musicLessons: return "book.fill"
        case .coverBand: return "guitars.fill"
        }
    }

    var description: String {
        switch self {
        case .findBandMembers: return "Looking for musicians to complete my band"
        case .startBand: return "Ready to form a new musical project from scratch"
        case .joinBand: return "Seeking an established band to join"
        case .casualJamSessions: return "Informal jam sessions for fun"
        case .studioCollaboration: return "Recording and producing music together"
        case .songwritingPartner: return "Co-writing songs and music"
        case .producerSearch: return "Finding a producer for my music"
        case .sessionMusician: return "Available for recording sessions"
        case .openMicBuddy: return "Partner for open mic nights"
        case .musicLessons: return "Teaching or learning music"
        case .coverBand: return "Playing covers and tributes"
        }
    }

    var color: Color {
        switch self {
        case .findBandMembers: return .orange
        case .startBand: return .purple
        case .joinBand: return .blue
        case .casualJamSessions: return .green
        case .studioCollaboration: return .red
        case .songwritingPartner: return .pink
        case .producerSearch: return .indigo
        case .sessionMusician: return .teal
        case .openMicBuddy: return .yellow
        case .musicLessons: return .cyan
        case .coverBand: return .mint
        }
    }
}

// MARK: - Instrument

enum Instrument: String, Codable, CaseIterable {
    case vocals = "vocals"
    case guitar = "guitar"
    case bass = "bass"
    case drums = "drums"
    case keyboard = "keyboard"
    case piano = "piano"
    case saxophone = "saxophone"
    case trumpet = "trumpet"
    case violin = "violin"
    case cello = "cello"
    case flute = "flute"
    case dj = "dj"
    case producer = "producer"
    case songwriter = "songwriter"
    case multiInstrumentalist = "multi_instrumentalist"

    var displayName: String {
        switch self {
        case .vocals: return "Vocals"
        case .guitar: return "Guitar"
        case .bass: return "Bass"
        case .drums: return "Drums"
        case .keyboard: return "Keyboard"
        case .piano: return "Piano"
        case .saxophone: return "Saxophone"
        case .trumpet: return "Trumpet"
        case .violin: return "Violin"
        case .cello: return "Cello"
        case .flute: return "Flute"
        case .dj: return "DJ"
        case .producer: return "Producer"
        case .songwriter: return "Songwriter"
        case .multiInstrumentalist: return "Multi-Instrumentalist"
        }
    }

    var icon: String {
        switch self {
        case .vocals: return "mic.fill"
        case .guitar: return "guitars.fill"
        case .bass: return "guitars"
        case .drums: return "drum.fill"
        case .keyboard: return "pianokeys"
        case .piano: return "pianokeys.inverse"
        case .saxophone: return "music.note"
        case .trumpet: return "music.note.tv"
        case .violin: return "music.quarternote.3"
        case .cello: return "music.quarternote.3"
        case .flute: return "wind"
        case .dj: return "hifispeaker.fill"
        case .producer: return "slider.horizontal.3"
        case .songwriter: return "pencil.and.outline"
        case .multiInstrumentalist: return "star.fill"
        }
    }
}

// MARK: - Music Genre

enum MusicGenre: String, Codable, CaseIterable {
    case rock = "rock"
    case pop = "pop"
    case jazz = "jazz"
    case blues = "blues"
    case country = "country"
    case folk = "folk"
    case classical = "classical"
    case hiphop = "hiphop"
    case rnb = "rnb"
    case electronic = "electronic"
    case metal = "metal"
    case punk = "punk"
    case indie = "indie"
    case soul = "soul"
    case funk = "funk"
    case reggae = "reggae"
    case latin = "latin"
    case world = "world"

    var displayName: String {
        switch self {
        case .rock: return "Rock"
        case .pop: return "Pop"
        case .jazz: return "Jazz"
        case .blues: return "Blues"
        case .country: return "Country"
        case .folk: return "Folk"
        case .classical: return "Classical"
        case .hiphop: return "Hip-Hop"
        case .rnb: return "R&B"
        case .electronic: return "Electronic"
        case .metal: return "Metal"
        case .punk: return "Punk"
        case .indie: return "Indie"
        case .soul: return "Soul"
        case .funk: return "Funk"
        case .reggae: return "Reggae"
        case .latin: return "Latin"
        case .world: return "World Music"
        }
    }
}

// MARK: - Experience Level

enum ExperienceLevel: String, Codable, CaseIterable {
    case any = "any"
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case professional = "professional"

    var displayName: String {
        switch self {
        case .any: return "Any Experience Level"
        case .beginner: return "Beginner (0-2 years)"
        case .intermediate: return "Intermediate (2-5 years)"
        case .advanced: return "Advanced (5-10 years)"
        case .professional: return "Professional (10+ years)"
        }
    }

    var icon: String {
        switch self {
        case .any: return "sparkles"
        case .beginner: return "star"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.fill"
        case .professional: return "crown.fill"
        }
    }
}

// MARK: - Commitment Level

enum CommitmentLevel: String, Codable, CaseIterable {
    case any = "any"
    case seriousGigging = "serious_gigging"
    case casualFun = "casual_fun"
    case recordingOnly = "recording_only"
    case weekendWarrior = "weekend_warrior"

    var displayName: String {
        switch self {
        case .any: return "Any Commitment Level"
        case .seriousGigging: return "Serious/Gigging Regularly"
        case .casualFun: return "Casual/Just for Fun"
        case .recordingOnly: return "Recording Only"
        case .weekendWarrior: return "Weekend Warrior"
        }
    }

    var icon: String {
        switch self {
        case .any: return "checkmark.circle"
        case .seriousGigging: return "flame.fill"
        case .casualFun: return "face.smiling"
        case .recordingOnly: return "waveform"
        case .weekendWarrior: return "calendar.badge.clock"
        }
    }
}

// MARK: - Instrument Skill (for profile)

struct InstrumentSkill: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var instrument: Instrument
    var yearsPlayed: Int
    var skillLevel: ExperienceLevel

    var displayString: String {
        return "\(instrument.displayName) (\(yearsPlayed) years)"
    }
}

// MARK: - Music Link Type

enum MusicLinkType: String, Codable, CaseIterable {
    case soundCloud = "soundcloud"
    case spotify = "spotify"
    case youtube = "youtube"
    case bandcamp = "bandcamp"
    case appleMusic = "apple_music"
    case instagram = "instagram"
    case website = "website"

    var displayName: String {
        switch self {
        case .soundCloud: return "SoundCloud"
        case .spotify: return "Spotify"
        case .youtube: return "YouTube"
        case .bandcamp: return "Bandcamp"
        case .appleMusic: return "Apple Music"
        case .instagram: return "Instagram"
        case .website: return "Website"
        }
    }

    var icon: String {
        switch self {
        case .soundCloud: return "waveform"
        case .spotify: return "music.note"
        case .youtube: return "play.rectangle.fill"
        case .bandcamp: return "music.note.list"
        case .appleMusic: return "music.note"
        case .instagram: return "camera.fill"
        case .website: return "globe"
        }
    }
}

// MARK: - Music Link

struct MusicLink: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var type: MusicLinkType
    var url: String
}

// MARK: - Zodiac Sign

enum ZodiacSign: String, Codable, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var displayName: String {
        return rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .aries: return "♈︎"
        case .taurus: return "♉︎"
        case .gemini: return "♊︎"
        case .cancer: return "♋︎"
        case .leo: return "♌︎"
        case .virgo: return "♍︎"
        case .libra: return "♎︎"
        case .scorpio: return "♏︎"
        case .sagittarius: return "♐︎"
        case .capricorn: return "♑︎"
        case .aquarius: return "♒︎"
        case .pisces: return "♓︎"
        }
    }
}

// MARK: - Political View

enum PoliticalView: String, Codable, CaseIterable {
    case liberal = "liberal"
    case moderate = "moderate"
    case conservative = "conservative"
    case notPolitical = "not_political"
    case other = "other"

    var displayName: String {
        switch self {
        case .liberal: return "Liberal"
        case .moderate: return "Moderate"
        case .conservative: return "Conservative"
        case .notPolitical: return "Not Political"
        case .other: return "Other"
        }
    }
}

// MARK: - Filter Preset

struct FilterPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filter: SearchFilter
    var createdAt: Date
    var lastUsed: Date
    var usageCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        filter: SearchFilter,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.filter = filter
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Search History Entry

struct SearchHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let filter: SearchFilter
    let timestamp: Date
    let resultsCount: Int

    init(
        id: String = UUID().uuidString,
        filter: SearchFilter,
        timestamp: Date = Date(),
        resultsCount: Int
    ) {
        self.id = id
        self.filter = filter
        self.timestamp = timestamp
        self.resultsCount = resultsCount
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
