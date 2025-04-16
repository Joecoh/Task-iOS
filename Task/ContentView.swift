//
//  ContentView.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//

//
//  ContentView 2.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var showingAddTask = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.dueDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .onTapGesture {
                                viewModel.toggleCompletion(for: task)
                            }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: viewModel.deleteTask)
            }
            .navigationTitle("📅 My To-Do List")
            .toolbar {
                Button(action: { showingAddTask.toggle() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
