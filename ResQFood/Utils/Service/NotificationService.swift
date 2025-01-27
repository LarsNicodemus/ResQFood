//
//  NotificationManager.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 25.01.25.
//
import SwiftUI
import UserNotifications

class NotificationService: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    /// Plant eine Benachrichtigung mit einem Titel und einer Nachricht.
    /// - Parameters:
    ///   - title: Der Titel der Benachrichtigung.
    ///   - body: Der Text der Benachrichtigung.
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Fordert die Berechtigung für Benachrichtigungen an.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { success, error in }
    }
    
    /// Wird aufgerufen, wenn die Anwendung gestartet wird.
    /// - Parameters:
    ///   - application: Die Anwendung.
    ///   - launchOptions: Optionen, die beim Starten der Anwendung übergeben werden.
    /// - Returns: Ein Bool-Wert, der angibt, ob die Anwendung erfolgreich gestartet wurde.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    /// Wird aufgerufen, wenn eine Benachrichtigung präsentiert wird.
    /// - Parameters:
    ///   - center: Das Benachrichtigungszentrum.
    ///   - notification: Die Benachrichtigung.
    ///   - completionHandler: Ein Abschluss-Handler, der die Präsentationsoptionen angibt.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if UIApplication.shared.applicationState != .active {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([])
        }
    }
    
    /// Sendet eine Benachrichtigung mit einer Verzögerung.
    /// - Parameters:
    ///   - title: Der Titel der Benachrichtigung.
    ///   - message: Die Nachricht der Benachrichtigung.
    ///   - delay: Die Verzögerung in Sekunden.
    func sendNotificationWithDelay(title: String, message: String, delay: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Benachrichtigt den Benutzer über eine neue Spende in der Nähe.
    /// - Parameters:
    ///   - donation: Die neue Spende.
    func notifyNewDonationNearby(donation: FoodDonation) {
        scheduleNotification(
            title: "New Donation Nearby",
            body: "A \(donation.title) is available in your area"
        )
    }
    
    /// Benachrichtigt den Benutzer, dass eine Spende reserviert wurde.
    /// - Parameters:
    ///   - donation: Die reservierte Spende.
    func notifyDonationReserved(donation: FoodDonation) {
        scheduleNotification(
            title: "Donation Reserved",
            body: "\(donation.title) has been reserved"
        )
    }
    
    
    /// Benachrichtigt den Benutzer über eine neue Chatnachricht.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    ///   - senderName: Der Name des Absenders.
    ///   - message: Die Nachricht.
    func notifyNewChatMessage(chatID: String, senderName: String, message: String) {
        scheduleNotification(
            title: "New Message from \(senderName)",
            body: message
        )
    }
    
    /// Erstellt eine Benachrichtigung mit Aktionen.
    /// - Parameters:
    ///   - title: Der Titel der Benachrichtigung.
    ///   - body: Der Text der Benachrichtigung.
    func notificationWithActions(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_ACTION",
            title: "Accept",
            options: .foreground
        )
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_ACTION",
            title: "Decline",
            options: .destructive
        )
        
        let category = UNNotificationCategory(
            identifier: "DONATION_CATEGORY",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
