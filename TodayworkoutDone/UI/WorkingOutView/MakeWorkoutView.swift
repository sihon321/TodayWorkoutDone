//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI

struct MakeWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var routines: [Routine]
    @State private var editMode: EditMode
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(selectionWorkouts: Binding<[Workouts]>, editMode: EditMode = .active) {
        self._routines = .init(initialValue: selectionWorkouts.compactMap({ Routine(workouts: $0.wrappedValue) }))
        self._editMode = .init(initialValue: editMode)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($routines) { routine in
                    WorkingOutSection(routine: routine,
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
//                        injected.appState[\.userData.selectionWorkouts] = selectionWorkouts
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
        MakeWorkoutView(selectionWorkouts: .constant(Workouts.mockedData),
                        editMode: .active)
    }
}
