//  ContentView.swift
//  To-Do List
//
//  Created by Suryansh Khranger on 2024-02-24.
//

// TODO: add calender and daily planner

import SwiftUI

struct inputItem: Identifiable {
    var id = UUID()
    var text: String
    // adding on date and time attributes
    var date: Date?
    var time: Date?
}

// additional functionality of date and time
struct old_DateTimeSelector: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            DatePicker(
                "Select a Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct DateTimeSelector: View {
    @Binding var selectedDate: Date

    var body: some View {
        HStack {
            // Date picker
            Picker("Select a Date", selection: $selectedDate) {
                ForEach(1..<get_days_in_current_month()+1) { index in
                    Text("\(self.get_date(for: index))")
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .frame(height: 40) // Adjust height as needed
            .padding(4)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            
            // Time picker
            Picker("Select a Time", selection: $selectedDate) {
                ForEach(0..<24*2) { hour in
                    if (hour%2 == 0) {
                        Text("\(hour/2):00")
                            .tag(hour)
                    }
                    else {
                        Text("\(hour/2):30")
                            .tag(hour)
                    }
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .frame(height: 40) // Adjust height as needed
            .padding(4)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Helper function to generate dates
    private func get_date(for dayOffset: Int) -> String {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return ""
        }
        let date = calendar.date(byAdding: .day, value: dayOffset - 1, to: startOfMonth) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func get_days_in_current_month() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        return range.count
    }
}

struct ToDoListPage: View {
    // list to store string inputs
    @State var inputItems: [inputItem] = []
    @State var maxCapacity = 5
    // for date selector
    @State private var selectedDate = Date()
    @State private var selectedInputItemIndex: Int?

    var body: some View {
        // header
        Label("To-Do", systemImage: "list.bullet.clipboard")
            .labelStyle(.titleAndIcon)
            .font(.largeTitle)
            .imageScale(.large)
            .alignmentGuide(.leading) { _ in
                0
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        
        // items list
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(inputItems.indices, id: \.self) { i in
                    let current_index = i
                    // content of each row
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .imageScale(.large)
                            TextField("Enter Task", text: $inputItems[i].text)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    selectedInputItemIndex = i
                                    selectedDate = inputItems[i].date ?? Date()
                                    print("date set: ", inputItems[current_index].date ?? "nil")
                                }
                            if let date = inputItems[i].date {
                                Text(DateFormatter().string(from: date))
                            }
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.width > 0 { deleteItem(at: current_index) }
                                }
                        )
                        Divider().imageScale(.large)
                    }
                    if let selectedIndex = selectedInputItemIndex, selectedIndex == current_index {
                        DateTimeSelector(selectedDate: $selectedDate)
                            .padding([.top, .bottom], 10)
                            .background(
                                Color.black.opacity(0.3)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        selectedInputItemIndex = nil
                                    }
                            )
                    }
                }
            }
            .onAppear {
                addDefaultInputItems()
            }
        }
        .overlay(
            Group {
                if let lastItem = inputItems.last, !lastItem.text.isEmpty {
                    Color.clear.onAppear { addItem() }
                } else {
                    EmptyView()
                }
            }
        )
    }

    // functions
    func addDefaultInputItems() {
        let defaultItemCount = 5
        for _ in 0..<defaultItemCount {
            addItem()
        }
    }

    func addItem() {
        inputItems.append(inputItem(text: "", date: Date()))
    }

    func deleteItem(at i: Int) {
        inputItems.remove(at: i)
    }
}


#Preview {
    ToDoListPage()
}
