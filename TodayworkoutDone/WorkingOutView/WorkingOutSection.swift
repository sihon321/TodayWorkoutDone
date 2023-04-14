//
//  WorkingOutSection.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutSection: View {
    @Binding var workouts: Excercise
    @Binding var editMode: EditMode
    @State var list: [Int] = [1]
    var body: some View {
        VStack {
            Section {
                ForEach(list, id: \.self) { _ in
                    WorkingOutRow(workouts: $workouts, editMode: $editMode)
                        .padding(.bottom, 2)
                }
            } header: {
                WorkingOutHeader(workouts: $workouts)
            } footer: {
                WorkingOutFooter()
                    .onTapGesture {
                        list.append(1)
                    }
            }
        }
    }
}

struct WorkingOutSection_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var excercises = {
        let excercises = Excercise(context: dataController.container.viewContext)
        excercises.name = "name"
        excercises.category = "category"
        return excercises
    }()
    
    static var previews: some View {
        WorkingOutSection(workouts: .constant(excercises),
                          editMode: .constant(.active))
        .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
