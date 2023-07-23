//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI

struct MakeWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    @State private var editMode: EditMode = .active
    @Binding var selectionWorkouts: [Workouts]
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($selectionWorkouts) { workouts in
                    WorkingOutSection(workouts: workouts,
                                      editMode: $editMode)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        injected.appState[\.userData.selectionWorkouts] = selectionWorkouts
                        injected.appState[\.routing.homeView.workingOutView] = true
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutCategoryView.workoutListView] = false
                        injected.appState[\.routing.excerciseStartView.workoutView] = false
                    }
                }
            }
            .navigationTitle("타이틀")
            .listStyle(.grouped)
        }
    }
}

struct MakeWorkoutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        MakeWorkoutView(selectionWorkouts: .constant([]))
    }
}
