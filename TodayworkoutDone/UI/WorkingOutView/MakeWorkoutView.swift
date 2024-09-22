//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MakeWorkoutReducer {
    @ObservableState
    struct State: Equatable {
        var myRoutine: MyRoutine
        var editMode: EditMode = .inactive
        var titleSmall: Bool = false
        var selectionWorkouts: [Workout] = []
        var isEdit: Bool = false
    }
    
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

struct MakeWorkoutView: View {
    @Bindable var store: StoreOf<MakeWorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<MakeWorkoutReducer>

    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<MakeWorkoutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField("타이틀을 입력하세요", text: .constant(store.myRoutine.name))
                    .multilineTextAlignment(.leading)
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.leading], 15)
                ForEach(viewStore.myRoutine.routines) { routine in
                    WorkingOutSection(
                        store: Store(
                            initialState: WorkingOutSectionReducer.State(
                                routine: routine,
                                editMode: store.editMode
                            )
                        ) {
                            WorkingOutSectionReducer()
                        }
                    )
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
                                        })
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
                    if viewStore.isEdit {
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
