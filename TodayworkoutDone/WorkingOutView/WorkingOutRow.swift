//
//  WorkingOutRow.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutRow: View {
    @Binding var workouts: Excercise
    @Binding var editMode: EditMode
    @State private var isChecked: Bool = false
    @State private var prevWeight: String = "Weight"
    @State private var count: String = "count"
    @State private var weight: String = "weight"
    
    var body: some View {
        HStack {
            Toggle("", isOn: $isChecked)
                .toggleStyle(CheckboxToggleStyle(style: .square))
            Spacer()
            
            if editMode == .active {
                TextField("prevWeight", text: $prevWeight)
            } else {
                Text(prevWeight)
            }
            Spacer()
            if editMode == .active {
                TextField("count", text: $count)
            } else {
                Text(count)
            }
            Spacer()
            if editMode == .active {
                TextField("weight", text: $weight)
            } else {
                Text(weight)
            }
        }
    }
}

struct WorkingOutRow_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var excercises = {
        let excercises = Excercise(context: dataController.container.viewContext)
        excercises.name = "name"
        excercises.category = "category"
        return excercises
    }()
    static var previews: some View {
        WorkingOutRow(workouts: .constant(excercises),
                      editMode: .constant(.active))
        .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
