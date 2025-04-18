//
//  TaskRowView.swift
//  Task
//
//  Created by Joash Cohen on 18/04/25.
//


import SwiftUI

struct TaskRowView: View {
    @ObservedObject var viewModel: TaskViewModel
    var task: Task

    var body: some View {
        HStack {
            // Title with strikethrough if completed
            Text(task.title)
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)

            Spacer()

            // Button to toggle task completion
            Button(action: {
                viewModel.toggleCompletion(for: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .blue)
            }

            // Button to delete task
            Button(action: {
                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.deleteTask(at: IndexSet(integer: index))
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
