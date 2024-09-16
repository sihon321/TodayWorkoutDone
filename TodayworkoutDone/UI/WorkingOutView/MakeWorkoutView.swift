//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct MakeWorkoutView: View {
    @State private var myRoutine: MyRoutine = MyRoutine(id: UUID(), name: "", routines: [])
    @Binding var myRoutines: [MyRoutine]
    @Binding var workoutsList: [Workout]
    @State private var editMode: EditMode
    @State private var titleSmall: Bool = false
    @State private var selectionWorkouts: [Workout] = []

    var isEdit: Bool
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(myRoutine: Binding<MyRoutine>,
         myRoutines: Binding<[MyRoutine]> = .constant([]),
         workoutsList: Binding<[Workout]> = .constant([]),
         editMode: EditMode = .active,
         isEdit: Bool = false) {
        self._myRoutine = .init(initialValue: myRoutine.wrappedValue)
        self._myRoutines = .init(projectedValue: myRoutines)
        self._workoutsList = .init(projectedValue: workoutsList)
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
                .padding([.bottom], 30)
                Button(action: {
                    
                }) {
                    Text("add")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(.gray)
                        .padding([.leading, .trailing], 15)
                }
                .fullScreenCover(isPresented: .constant(false),
                                content: {
                    VStack {
                        NavigationView {
                            ScrollView {
                                VStack {
                                    WorkoutCategoryView(
                                        store: Store(initialState: WorkoutCategoryReducer.State()) {
                                            WorkoutCategoryReducer()
                                        },
                                        categories: [],
                                        workoutsList: workoutsList,
                                        selectWorkouts: selectionWorkouts,
                                        isMyWorkoutView: true,
                                        myRoutine: $myRoutine)
                                }
                            }
                        }
                    }
                })
                Spacer().frame(height: 100)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
//                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
//                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
//                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
//                        injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEdit {
                        Button("Save") {
//                            injected.interactors.routineInteractor.update(myRoutine: myRoutine) {
//                                injected.interactors.routineInteractor.load(myRoutines: $myRoutines)
//                                injected.appState[\.userData.myRoutine] = myRoutine
//                                injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
//                            }
                        }
                    } else {
                        Button("Done") {
//                            injected.appState[\.userData.myRoutine] = myRoutine
//                            injected.appState[\.routing.homeView.workingOutView] = true
//                            
//                            injected.appState[\.routing.workoutListView.makeWorkoutView] = false
//                            
//                            injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
//                            injected.appState[\.routing.workoutCategoryView.workoutListView] = false
//
//                            injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
//                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
}
