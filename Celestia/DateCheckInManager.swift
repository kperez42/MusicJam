//
//  JamSessionCheckInManager.swift
//  MusicJam
//
//  Manages jam session check-in and safety features for in-person meetups
//

import Foundation
import Combine
import CoreLocation

// MARK: - Jam Session Check-In Manager

@MainActor
class JamSessionCheckInManager: ObservableObject {

    // MARK: - Singleton

    static let shared = JamSessionCheckInManager()

    // MARK: - Published Properties

    @Published var activeCheckIns: [JamSessionCheckIn] = []
    @Published var scheduledCheckIns: [JamSessionCheckIn] = []
    @Published var pastCheckIns: [JamSessionCheckIn] = []
    @Published var hasActiveCheckIn: Bool = false

    // MARK: - Properties

    private var checkInTimers: [String: Timer] = [:]
    private let defaults = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        loadCheckIns()
        Logger.shared.info("JamSessionCheckInManager initialized", category: .general)
    }

    // MARK: - Check-In Management

    /// Schedule a jam session check-in
    func scheduleCheckIn(
        musicianId: String,
        musicianName: String,
        location: String,
        scheduledTime: Date,
        checkInTime: Date,
        emergencyContacts: [EmergencyContact]
    ) async throws -> JamSessionCheckIn {

        Logger.shared.info("Scheduling check-in for jam session with: \(musicianName)", category: .general)

        // Validate times
        guard scheduledTime > Date() else {
            throw MusicJamError.invalidData
        }

        guard checkInTime > scheduledTime else {
            throw MusicJamError.invalidData
        }

        // Create check-in
        let checkIn = JamSessionCheckIn(
            id: UUID().uuidString,
            musicianId: musicianId,
            musicianName: musicianName,
            location: location,
            scheduledTime: scheduledTime,
            checkInTime: checkInTime,
            emergencyContacts: emergencyContacts,
            status: .scheduled
        )

        // Add to scheduled list
        scheduledCheckIns.append(checkIn)
        saveCheckIns()

        // Schedule notifications
        try await scheduleCheckInNotifications(for: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.dateCheckInScheduled, parameters: [
            "musician_id": musicianId,
            "scheduled_time": scheduledTime.timeIntervalSince1970
        ])

        Logger.shared.info("Jam session check-in scheduled successfully", category: .general)

        return checkIn
    }

    /// Start an active check-in
    func startCheckIn(checkInId: String) async throws {
        guard let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw MusicJamError.checkInNotFound
        }

        var checkIn = scheduledCheckIns.remove(at: index)
        checkIn.status = .active
        checkIn.activatedAt = Date()

        activeCheckIns.append(checkIn)
        hasActiveCheckIn = true
        saveCheckIns()

        // Start monitoring
        startMonitoring(checkIn: checkIn)

        // Notify emergency contacts
        await notifyEmergencyContacts(checkIn: checkIn, message: "Jam session check-in started with \(checkIn.musicianName)")

        // Track analytics
        AnalyticsManager.shared.logEvent(.dateCheckInStarted, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.info("Jam session check-in started: \(checkInId)", category: .general)
    }

    /// Complete a check-in (user is safe)
    func completeCheckIn(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw MusicJamError.checkInNotFound
        }

        var checkIn = activeCheckIns.remove(at: index)
        checkIn.status = .completed
        checkIn.completedAt = Date()

        pastCheckIns.insert(checkIn, at: 0)
        hasActiveCheckIn = activeCheckIns.isEmpty == false
        saveCheckIns()

        // Stop monitoring
        stopMonitoring(checkInId: checkInId)

        // Notify emergency contacts
        await notifyEmergencyContacts(checkIn: checkIn, message: "Jam session check-in completed successfully")

        // Track analytics
        AnalyticsManager.shared.logEvent(.dateCheckInCompleted, parameters: [
            "check_in_id": checkInId,
            "duration": checkIn.completedAt?.timeIntervalSince(checkIn.activatedAt ?? Date()) ?? 0
        ])

        Logger.shared.info("Jam session check-in completed: \(checkInId)", category: .general)
    }

    /// Cancel a check-in
    func cancelCheckIn(checkInId: String) async throws {
        // Check scheduled list
        if let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = scheduledCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            saveCheckIns()

            Logger.shared.info("Scheduled jam session check-in cancelled: \(checkInId)", category: .general)
            return
        }

        // Check active list
        if let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = activeCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            hasActiveCheckIn = activeCheckIns.isEmpty == false
            saveCheckIns()

            stopMonitoring(checkInId: checkInId)

            Logger.shared.info("Active jam session check-in cancelled: \(checkInId)", category: .general)
            return
        }

        throw MusicJamError.checkInNotFound
    }

    /// Trigger emergency alert
    func triggerEmergency(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw MusicJamError.checkInNotFound
        }

        var checkIn = activeCheckIns[index]
        checkIn.status = .emergency
        activeCheckIns[index] = checkIn
        saveCheckIns()

        // Send emergency notifications
        await sendEmergencyAlerts(checkIn: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.emergencyTriggered, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.warning("Emergency triggered for jam session check-in: \(checkInId)", category: .general)
    }

    // MARK: - Monitoring

    private func startMonitoring(checkIn: JamSessionCheckIn) {
        // Set up timer to check if user checks in on time
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkCheckInStatus(checkIn: checkIn)
            }
        }

        checkInTimers[checkIn.id] = timer
    }

    private func stopMonitoring(checkInId: String) {
        checkInTimers[checkInId]?.invalidate()
        checkInTimers.removeValue(forKey: checkInId)
    }

    private func checkCheckInStatus(checkIn: JamSessionCheckIn) async {
        // Check if check-in time has passed
        guard Date() > checkIn.checkInTime else { return }

        // If user hasn't checked in, trigger alert
        if checkIn.status == .active {
            Logger.shared.warning("Jam session check-in overdue: \(checkIn.id)", category: .general)

            // Send warning notification
            await notifyEmergencyContacts(
                checkIn: checkIn,
                message: "Jam session check-in overdue for session with \(checkIn.musicianName)"
            )

            // Trigger emergency after grace period
            let gracePeriod: TimeInterval = 15 * 60 // 15 minutes
            if Date().timeIntervalSince(checkIn.checkInTime) > gracePeriod {
                try? await triggerEmergency(checkInId: checkIn.id)
            }
        }
    }

    // MARK: - Notifications

    private func scheduleCheckInNotifications(for checkIn: JamSessionCheckIn) async throws {
        // Schedule reminder before session
        // Schedule check-in reminder
        // In production, use UNUserNotificationCenter
        Logger.shared.debug("Scheduled notifications for jam session check-in: \(checkIn.id)", category: .general)
    }

    private func notifyEmergencyContacts(checkIn: JamSessionCheckIn, message: String) async {
        for contact in checkIn.emergencyContacts {
            // In production, send SMS or call emergency contacts
            Logger.shared.info("Notifying emergency contact: \(contact.name)", category: .general)
        }
    }

    private func sendEmergencyAlerts(checkIn: JamSessionCheckIn) async {
        // Send emergency SMS/calls to all contacts
        // Include location, musician info, and emergency details
        for contact in checkIn.emergencyContacts {
            Logger.shared.warning("EMERGENCY: Notifying \(contact.name) about jam session with \(checkIn.musicianName)", category: .general)
        }

        // In production, also:
        // - Call emergency services if no response
        // - Send location updates
        // - Trigger loud alarm on device
    }

    // MARK: - Persistence

    private func loadCheckIns() {
        // Load from UserDefaults or database
        // In production, use Firestore or Core Data
    }

    private func saveCheckIns() {
        // Save to UserDefaults or database
    }

    // MARK: - Cleanup

    func cleanup() {
        // Cancel all timers
        for timer in checkInTimers.values {
            timer.invalidate()
        }
        checkInTimers.removeAll()
    }
}

// Alias for backward compatibility
typealias DateCheckInManager = JamSessionCheckInManager

// MARK: - Jam Session Check-In Model

struct JamSessionCheckIn: Identifiable, Codable {
    let id: String
    let musicianId: String
    let musicianName: String
    let location: String
    let scheduledTime: Date
    let checkInTime: Date
    let emergencyContacts: [EmergencyContact]
    var status: CheckInStatus
    var activatedAt: Date?
    var completedAt: Date?

    enum CheckInStatus: String, Codable {
        case scheduled
        case active
        case completed
        case cancelled
        case emergency
    }
}

// Alias for backward compatibility
typealias DateCheckIn = JamSessionCheckIn
