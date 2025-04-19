//
//  AddTaskView.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var shouldRemind = false
    @State private var reminderDate = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $title)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                
                Toggle("Set Reminder", isOn: $shouldRemind)
                
                if shouldRemind {
                    DatePicker("Reminder Time", selection: $reminderDate)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // Pass reminder data to the view model
                        viewModel.addTask(
                            title: title,
                            dueDate: dueDate,
                            shouldRemind: shouldRemind,
                            reminderDate: shouldRemind ? reminderDate : nil
                        )
                        dismiss()
                    }.disabled(title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
