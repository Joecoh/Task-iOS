//
//  TaskApp.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//
import Foundation

class Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false
    var isPinned: Bool = false
    var shouldRemind: Bool = false
    var reminderDate: Date?

    init(title: String, dueDate: Date, shouldRemind: Bool = false, reminderDate: Date? = nil) {
        self.title = title
        self.dueDate = dueDate
        self.shouldRemind = shouldRemind
        self.reminderDate = reminderDate
    }
}
