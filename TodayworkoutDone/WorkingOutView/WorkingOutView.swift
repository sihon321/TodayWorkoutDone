//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    @State private var editMode: EditMode = .active
    @Binding var selectionWorkouts: [Excercise]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($selectionWorkouts) { excercise in
                        WorkingOutSection(workouts: excercise,
                                          editMode: $editMode)
                    }
                }
                .toolbar {
                    EditButton()
                }
                .environment(\.editMode, $editMode)
                .navigationTitle("타이틀")
                .listStyle(.grouped)
            }
        }
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    
    static var previews: some View {
        WorkingOutView(selectionWorkouts: .constant([]))
    }
}
