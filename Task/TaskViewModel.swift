//
//  TaskViewModel.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import Foundation
import UserNotifications

enum TaskFilter {
    case all
    case completed
    case taskDue
    case upcoming
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet { saveTasks() }
    }
    @Published var currentFilter: TaskFilter = .all

    var filteredTasks: [Task] {
        switch currentFilter {
        case .completed:
            return tasks.filter { $0.isCompleted }
        case .taskDue:
            return tasks.filter { !$0.isCompleted && $0.dueDate <= Date() }
        case .upcoming:
            return tasks.filter {
                !$0.isCompleted &&
                $0.dueDate > Date() &&
                !Calendar.current.isDateInToday($0.dueDate)
            }
        case .all:
            return tasks
        }
    }

    init() {
        loadTasks()
    }

    private func loadTasks() {
        let url = getTasksURL()
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }

    func addTask(title: String, dueDate: Date) {
        let newTask = Task(title: title, dueDate: dueDate)
        tasks.append(newTask)
        saveTasks()
        scheduleNotification(for: newTask)
    }

    func toggleCompletion(for task: Task) {
        // 1) Tell SwiftUI we’re about to change something
        objectWillChange.send()

        // 2) Toggle the flag
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()

            // 3) Cancel notification if completed
            if tasks[index].isCompleted {
                UNUserNotificationCenter
                  .current()
                  .removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
            }

            // 4) Persist the change
            saveTasks()
        }
    }


    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    private func getTasksURL() -> URL {
        FileManager
          .default
          .urls(for: .documentDirectory, in: .userDomainMask)[0]
          .appendingPathComponent("tasks.json")
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            try? data.write(to: getTasksURL())
        }
    }

    private func scheduleNotification(for task: Task) {
        guard !task.isCompleted else { return }
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body  = task.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
