//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct WorkoutPresent {
    enum Action {
        case dismiss
    }
}

@Reducer
struct WorkoutReducer {
    @ObservableState
    struct State: Equatable {
        var workoutsList: [Workout] = []
        var keyword: String = ""
        var workoutCategory = WorkoutCategoryReducer.State()
    }
    
    enum Action {
        case search(keyword: String)
        case workoutCategory(WorkoutCategoryReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                state.keyword = keyword
                return .none
            case .workoutCategory(.setText(let keyword)):
                state.workoutCategory.keyword = keyword
                return .none
            }
        }
    }
}

struct WorkoutView: View {
    @Bindable var store: StoreOf<WorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutReducer>
    @Bindable var presentStore: StoreOf<WorkoutPresent>
    
    @State private var workoutsList: [Workout] = []
    
    init(store: StoreOf<WorkoutReducer>,
         presentStore: StoreOf<WorkoutPresent>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.presentStore = presentStore
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    MyWorkoutView(myRoutines: [],
                                  workoutsList: $workoutsList)
                        .padding(.top, 10)
                    WorkoutCategoryView(
                        store: store.scope(state: \.workoutCategory,
                                           action: \.workoutCategory), 
                        categories: [],
                        workoutsList: workoutsList,
                        selectWorkouts: [])
                    .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
        }
        .searchable(text: viewStore.binding(
            get: { $0.keyword },
            send: { WorkoutReducer.Action.search(keyword: $0) }
        ))
    }
}

extension WorkoutView {
    func reloadWorkouts() {
//        injected.interactors.workoutInteractor
//            .load(workouts: $workoutsList)
    }
}
