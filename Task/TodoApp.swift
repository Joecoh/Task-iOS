//
//  TodoApp.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import SwiftUI
import UserNotifications

@main
struct TodoApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("✅ Notification permission granted.")
            } else {
                print("❌ Notification permission denied.")
            }
        }

    }

    var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
}
