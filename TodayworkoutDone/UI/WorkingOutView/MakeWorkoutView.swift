//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import Combine

struct MakeWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var routingState: Routing = .init()
    @State private var myRoutine: MyRoutine
    @Binding var myRoutines: Loadable<LazyList<MyRoutine>>
    @Binding var workoutsList: Loadable<LazyList<Workouts>>
    @State private var editMode: EditMode
    @State private var titleSmall: Bool = false
    @State private var selectionWorkouts: [Workouts] = []
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.makeWorkoutView)
    }
    var isEdit: Bool
    @State private var isAppendSets = true
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(myRoutine: Binding<MyRoutine>,
         myRoutines: Binding<Loadable<LazyList<MyRoutine>>> = .constant(.notRequested),
         workoutsList: Binding<Loadable<LazyList<Workouts>>> = .constant(.notRequested),
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
                                      editMode: $editMode,
                                      isAppendSets: $isAppendSets)
                }
                .padding([.bottom], 30)
                Button(action: {
                    injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = true
                }) {
                    Text("add")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(.gray)
                        .padding([.leading, .trailing], 15)
                }
                .fullScreenCover(isPresented: routingBinding.workoutCategoryView,
                                content: {
                    VStack {
                        NavigationView {
                            ScrollView {
                                VStack {
                                    WorkoutCategoryView(workoutsList: workoutsList,
                                                        selectWorkouts: injected.appState[\.userData].selectionWorkouts,
                                                        isMyWorkoutView: true,
                                                        myRoutine: $myRoutine)
                                        .inject(injected)
                                        .onAppear {
                                            isAppendSets = false
                                        }
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
                        injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = false
                        injected.appState[\.routing.workoutListView.makeWorkoutView] = false
                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                        injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEdit {
                        Button("Save") {
                            injected.interactors.routineInteractor.update(myRoutine: myRoutine) {
                                injected.interactors.routineInteractor.load(myRoutines: $myRoutines)
                                injected.appState[\.userData.myRoutine] = myRoutine
                                injected.appState[\.routing.myWorkoutView.makeWorkoutView] = false
                            }
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
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
}

extension MakeWorkoutView {
    struct Routing: Equatable {
        var workoutCategoryView: Bool = false
    }
}

private extension MakeWorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.makeWorkoutView)
    }
    
    var myRoutineUpdate: AnyPublisher<MyRoutine, Never> {
        injected.appState.updates(for: \.userData.myRoutine)
    }
}

struct MakeWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MakeWorkoutView(myRoutine: .constant(MyRoutine.mockedData),
                        editMode: .active)
    }
}
