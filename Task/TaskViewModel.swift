//
//  TaskViewModel.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import Foundation
import UserNotifications

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }

    init() {
        loadTasks()
    }

    func addTask(title: String, dueDate: Date) {
        let newTask = Task(title: title, dueDate: dueDate)
        tasks.append(newTask)
        scheduleNotification(for: newTask)
    }

    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    private func getTasksURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tasks.json")
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            try? data.write(to: getTasksURL())
        }
    }

    private func loadTasks() {
        let url = getTasksURL()
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }

    private func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
