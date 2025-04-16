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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
