//
//  TaskListView.swift
//  Task
//
//  Created by Joash Cohen on 18/04/25.
//


import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingAddTaskView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredTasks) { task in
                    // Fix: Correct the argument order
                    TaskRowView(viewModel: viewModel, task: task)
                }
                .onDelete { indexSet in
                    viewModel.deleteTask(at: indexSet)
                }
            }
            .navigationBarTitle("Tasks")
            .navigationBarItems(trailing: Button("Add") {
                showingAddTaskView.toggle()
            })
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
}

