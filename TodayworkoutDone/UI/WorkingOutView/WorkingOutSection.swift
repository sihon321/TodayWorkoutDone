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
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var body: some View {
        VStack {
            Section {
                List {
                    ForEach(list, id: \.self) { item in
                        WorkingOutRow(workouts: $workouts, editMode: $editMode)
                            .padding(.bottom, 2)
                    }
                    .onDelete { indexSet in
                        deleteItems(atOffsets: indexSet)
                    }
                }
                .frame(minHeight: minRowHeight * CGFloat(list.count))
                .listStyle(PlainListStyle())
            } header: {
                WorkingOutHeader(workouts: $workouts)
            } footer: {
                WorkingOutFooter()
                    .onTapGesture {
                        if let lastNumber = list.last {
                            list.append(lastNumber + 1)
                        } else {
                            list.append(1)
                        }
                    }
            }
        }
    }
    
    func deleteItems(atOffsets offset: IndexSet) {
        list.remove(atOffsets: offset)
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
