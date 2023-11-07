//
//  WorkingOutSection.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutSection: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @Binding var routine: Routine
    @Binding var editMode: EditMode
    @Binding var isAppendSets: Bool
    
    var body: some View {
        VStack {
            Section {
                List {
                    ForEach(routine.sets) { sets in
                        WorkingOutRow(sets: .constant(sets),
                                      editMode: $editMode)
                            .padding(.bottom, 2)
                    }
                    .onDelete { indexSet in
                        deleteItems(atOffsets: indexSet)
                    }
                }
                .frame(minHeight: minRowHeight * CGFloat(routine.sets.count))
                .listStyle(PlainListStyle())
            } header: {
                WorkingOutHeader(routine: $routine)
            } footer: {
                WorkingOutFooter()
                    .onTapGesture {
                        isAppendSets = true
                        routine.sets.append(Sets())
                    }
            }
        }
    }
    
    func deleteItems(atOffsets offset: IndexSet) {
        routine.sets.remove(atOffsets: offset)
    }
}

struct WorkingOutSection_Previews: PreviewProvider {
    static var routine = {
        return Routine(workouts: Workouts(name: "test",
                                          category: "test_category",
                                          target: "test_target"))
    }()
    
    static var previews: some View {
        WorkingOutSection(routine: .constant(routine),
                          editMode: .constant(.active),
                          isAppendSets: .constant(false))
    }
}
