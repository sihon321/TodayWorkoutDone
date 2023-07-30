//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var editMode: EditMode = .active
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    private var selectWorkouts: [Workouts] {
        injected.appState[\.userData.selectionWorkouts]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(selectWorkouts) { workouts in
                    WorkingOutSection(
                        routine: .constant(Routine(workouts: workouts)),
                        editMode: $editMode
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {

                    }
                }
            }
            .navigationTitle("타이틀")
            .listStyle(.grouped)
        }
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkingOutView()
    }
}
