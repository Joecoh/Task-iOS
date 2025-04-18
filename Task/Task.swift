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

    init(title: String, dueDate: Date, isCompleted: Bool = false) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
