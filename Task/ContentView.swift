
//
//  ContentView.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var editingTask: Task? = nil
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var shouldRemind = false
    @State private var reminderDate = Date()
    @State private var showTitleAlert = false
    
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredTasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.dueDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if task.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.small)
                                .padding(.trailing, 5)
                        }
                        
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .onTapGesture {
                                viewModel.toggleCompletion(for: task)
                            }
                    }
                    .padding(.vertical, 5)
                    .contextMenu {
                        Button {
                            editingTask = task
                            title = task.title
                            dueDate = task.dueDate
                            shouldRemind = task.shouldRemind
                            reminderDate = task.reminderDate ?? Date()
                            showingAddTask.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                viewModel.tasks.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            viewModel.togglePin(for: task)
                        } label: {
                            Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? "pin.slash" : "pin")
                        }
                    }
                    .onLongPressGesture {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        viewModel.togglePin(for: task)
                    }
                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            editingTask = task
                            title = task.title
                            dueDate = task.dueDate
                            shouldRemind = task.shouldRemind
                            reminderDate = task.reminderDate ?? Date()
                            showingAddTask.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        .tint(.blue)
                        
                        Button(role: .destructive) {
                            if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                viewModel.tasks.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.togglePin(for: task)
                        } label: {
                            Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? "pin.slash" : "pin")
                        }
                        .tint(task.isPinned ? .gray : .yellow)
                        
                        Button {
                            viewModel.toggleCompletion(for: task)
                        } label: {
                            Label("Complete", systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .tint(task.isCompleted ? .gray : .green)
                    }
                    
                }
                .onDelete(perform: viewModel.deleteTask)
            }
            .navigationTitle("📋 My TASK")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingTask = nil
                        title = ""
                        dueDate = Date()
                        showingAddTask.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All Tasks") { viewModel.currentFilter = .all }
                        Button("Completed") { viewModel.currentFilter = .completed }
                        Button("Task Due") { viewModel.currentFilter = .taskDue }
                        Button("Upcoming") { viewModel.currentFilter = .upcoming }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                VStack {
                    TextField("Task Title", text: $title)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .padding()
                    
                    Toggle("Set Reminder", isOn: $shouldRemind)
                        .padding()
                    
                    if shouldRemind {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        
                    }
                    
                    HStack {
                        Button("Cancel") {
                            showingAddTask = false
                            title = ""
                            dueDate = Date()
                            shouldRemind = false
                            reminderDate = Date()
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Save") {
                            let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
                            if trimmedTitle.isEmpty {
                                showTitleAlert = true
                                return
                            }
                            
                            
                            if let editingTask = editingTask {
                                viewModel.updateTask(
                                    editingTask,
                                    withTitle: trimmedTitle,
                                    dueDate: dueDate,
                                    shouldRemind: shouldRemind,
                                    reminderDate: shouldRemind ? reminderDate : nil
                                )
                            } else {
                                viewModel.addTask(
                                    title: trimmedTitle,
                                    dueDate: dueDate,
                                    shouldRemind: shouldRemind,
                                    reminderDate: shouldRemind ? reminderDate : nil
                                )
                            }
                            
                            showingAddTask = false
                            title = ""
                            dueDate = Date()
                            shouldRemind = false
                            reminderDate = Date()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding()
                        .background(title.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                }
                .padding()
                .alert("Please enter a task title", isPresented: $showTitleAlert) {
                    Button("OK", role: .cancel) { }
                }
                
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
