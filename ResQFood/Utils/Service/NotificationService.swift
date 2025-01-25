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
    
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { success, error in }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
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
    
    func sendNotificationWithDelay(title: String, message: String, delay: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    func notifyNewDonationNearby(donation: FoodDonation) {
        scheduleNotification(
            title: "New Donation Nearby",
            body: "A \(donation.title) is available in your area"
        )
    }
    
    func notifyDonationReserved(donation: FoodDonation) {
        scheduleNotification(
            title: "Donation Reserved",
            body: "\(donation.title) has been reserved"
        )
    }
    
    
    
    func notifyNewChatMessage(chatID: String, senderName: String, message: String) {
        scheduleNotification(
            title: "New Message from \(senderName)",
            body: message
        )
    }
    
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
