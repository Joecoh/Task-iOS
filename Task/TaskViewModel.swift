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
        func sortPinnedFirst(_ tasks: [Task]) -> [Task] {
            return tasks.sorted { $0.isPinned && !$1.isPinned }
        }

        switch currentFilter {
        case .all:
            return sortPinnedFirst(tasks)
        case .completed:
            return sortPinnedFirst(tasks.filter { $0.isCompleted })
        case .taskDue:
            return sortPinnedFirst(tasks.filter { !$0.isCompleted && $0.dueDate <= Date() })
        case .upcoming:
            return sortPinnedFirst(tasks.filter {
                !$0.isCompleted &&
                $0.dueDate > Date() &&
                !Calendar.current.isDateInToday($0.dueDate)
            })
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

    func addTask(title: String, dueDate: Date, shouldRemind: Bool, reminderDate: Date?) {
        let newTask = Task(title: title, dueDate: dueDate, shouldRemind: shouldRemind, reminderDate: reminderDate)
        tasks.append(newTask)
        saveTasks()
        if shouldRemind, let reminderDate = reminderDate {
            scheduleNotification(for: newTask, at: reminderDate)
        }
    }

    func updateTask(
        _ task: Task,
        withTitle title: String,
        dueDate: Date,
        shouldRemind: Bool,
        reminderDate: Date?
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        // 1. Cancel any existing reminder for this task
        UNUserNotificationCenter
          .current()
          .removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])

        // 2. Update the model
        tasks[index].title        = title
        tasks[index].dueDate      = dueDate
        tasks[index].shouldRemind = shouldRemind
        tasks[index].reminderDate = reminderDate
        tasks[index].isCompleted  = false

        saveTasks()

        // 3. Schedule a new notification if needed
        if shouldRemind, let date = reminderDate {
            scheduleNotification(for: tasks[index], at: date)
        }
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
    func togglePin(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isPinned.toggle()
            
            // Trigger tasks update to refresh filteredTasks immediately
            tasks = tasks.sorted { $0.isPinned && !$1.isPinned }
        }
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

    private func scheduleNotification(for task: Task, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
