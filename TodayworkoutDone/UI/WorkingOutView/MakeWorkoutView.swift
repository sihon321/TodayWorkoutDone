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
    
    var isEdit: Bool
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(myRoutine: Binding<MyRoutine>, editMode: EditMode = .active, isEdit: Bool = false) {
        self._myRoutine = .init(initialValue: myRoutine.wrappedValue)
        self._editMode = .init(initialValue: editMode)
        self.isEdit = isEdit
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
                Spacer().frame(height: 100)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                        injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEdit {
                        Button("Save") {
                            injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                            injected.interactors.routineInteractor.update(myRoutine: myRoutine)
                        }
                    } else {
                        Button("Done") {
                            injected.appState[\.userData.myRoutine] = myRoutine
                            injected.appState[\.routing.homeView.workingOutView] = true
                            injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                            injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                            injected.appState[\.routing.workoutCategoryView.workoutListView] = false
                            injected.appState[\.routing.excerciseStartView.workoutView] = false
                            injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                        }
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
