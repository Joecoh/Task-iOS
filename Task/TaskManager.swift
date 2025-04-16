//
//  TaskManager.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import Foundation

class TaskManager: ObservableObject {
    @Published var tasks = [Task]()

    init() {
        loadTasks()
    }
    
    func addTask(title: String, dueDate: Date) {
        let newTask = Task(title: title, dueDate: dueDate)
        tasks.append(newTask)
        saveTasks()
    }
    
    func toggleCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
    }
}
