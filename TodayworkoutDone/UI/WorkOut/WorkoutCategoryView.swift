//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Dependencies
import ComposableArchitecture

@Reducer
struct WorkoutCategoryReducer {
    @ObservableState
    struct State: Equatable {
        var keyword: String = ""
        var categories: Categories = []
        var workoutsList: [Workout] = []
        var selectWorkouts: [Workout] = []
        var isMyWorkoutView: Bool = false
        var myRoutine: MyRoutine = MyRoutine(name: "", routines: [])
    }
    
    enum Action {
        case setText(keyword: String)
        case getCategories
        case updateCategories(Categories)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setText(_):
                return .none
            case .getCategories:
                return .none
            case .updateCategories(_):
                return .none
            }
        }
    }
}

struct WorkoutCategoryView: View {
    @Bindable var store: StoreOf<WorkoutCategoryReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutCategoryReducer>
    
    init(store: StoreOf<WorkoutCategoryReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            let filteredCategory = viewStore.workoutsList
                .filter({ $0.name.hasPrefix(store.keyword) })
                .compactMap({ $0.category })
                .uniqued()
            let categories = viewStore.categories.filter {
                if filteredCategory.isEmpty {
                    return true
                } else if filteredCategory.contains($0.name) {
                    return true
                } else {
                    return false
                }
            }
            ForEach(categories) { category in
                NavigationLink {
                    WorkoutListView(
                        store: Store(
                            initialState: WorkoutListReducer.State(
                                workoutsList: store.workoutsList,
                                selectWorkouts: store.selectWorkouts,
                                myRoutine: viewStore.myRoutine,
                                isMyWorkoutView: store.isMyWorkoutView,
                                category: category)
                        ) {
                            WorkoutListReducer()
                        }
                    )
                } label: {
                    WorkoutCategorySubview(category: category.name)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !viewStore.selectWorkouts.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !viewStore.isMyWorkoutView {
                            
                        } else {
                            store.myRoutine.routines += viewStore.selectWorkouts.compactMap({ Routine(workouts: $0) })
//                            injected.appState[\.userData.selectionWorkouts].removeAll()
//                            injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                        }
                    }) {
                        Text("Done(\(viewStore.selectWorkouts.count))")
                    }
                    .fullScreenCover(isPresented: .constant(false),
                                     content: {
                        if !viewStore.isMyWorkoutView {
                            MakeWorkoutView(
                                store: Store(initialState: MakeWorkoutReducer.State()) {
                                    MakeWorkoutReducer()
                                }
                            )
                        }
                    })
                }
            }
            if viewStore.isMyWorkoutView {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
//                        injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            }
        }
        .onAppear {
            store.send(.getCategories)
        }
    }
}
