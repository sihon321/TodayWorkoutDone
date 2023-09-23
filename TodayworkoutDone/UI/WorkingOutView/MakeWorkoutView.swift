//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI

struct MakeWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var myRoutine: MyRoutine
    @State private var editMode: EditMode
    
    @State private var titleSmall: Bool = false
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(myRoutine: Binding<MyRoutine>, editMode: EditMode = .active) {
        print("sihoon init \(myRoutine.name.wrappedValue)")
        self._myRoutine = .init(initialValue: myRoutine.wrappedValue)
        self._editMode = .init(initialValue: editMode)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField("타이틀을 입력하세요", text: $myRoutine.name)
                    .multilineTextAlignment(.leading)
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.leading], 15)
                ForEach($myRoutine.routines) { routine in
                    WorkingOutSection(routine: routine,
                                      editMode: $editMode)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        injected.appState[\.userData.myRoutine] = myRoutine
                        injected.appState[\.routing.homeView.workingOutView] = true
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutCategoryView.workoutListView] = false
                        injected.appState[\.routing.excerciseStartView.workoutView] = false
                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
}

struct MakeWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MakeWorkoutView(myRoutine: .constant(MyRoutine.mockedData),
                        editMode: .active)
    }
}
