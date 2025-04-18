//
//  TaskApp.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//

import Foundation

class Task: Identifiable, Codable {
    var id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false

    init(title: String, dueDate: Date) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
    }
}
