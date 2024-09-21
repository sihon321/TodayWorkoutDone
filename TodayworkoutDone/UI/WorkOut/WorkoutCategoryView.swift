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
        var isMyWorkoutView: Bool = false
        var myRoutine: MyRoutine = MyRoutine(name: "", routines: [])

        var workoutList = WorkoutListReducer.State()
        
        var isEmptySelectedWorkouts: Bool {
            var isEmpty = true
            for workouts in workoutList.workouts {
                if workouts.isSelected {
                    isEmpty = false
                    break
                }
            }
            return isEmpty
        }
    }
    
    enum Action {
        case setText(keyword: String)
        case getCategories
        case updateCategories(Categories)
        case workoutList(WorkoutListReducer.Action)
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
            case .workoutList(.getWorkouts):
                return .none
            case .workoutList(.updateWorkouts(_)):
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
            let filteredCategory = viewStore.workoutList.workouts
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
                        store: store.scope(state: \.workoutList,
                                           action: \.workoutList),
                        category: category
                    )
                } label: {
                    WorkoutCategorySubview(category: category)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !viewStore.isEmptySelectedWorkouts {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !viewStore.isMyWorkoutView {
                            
                        } else {
                            store.myRoutine.routines += viewStore.workoutList.workouts
                                .filter({ $0.isSelected })
                                .compactMap({ Routine(workouts: $0) })
                        }
                    }) {
                        let selectedWorkout = viewStore.workoutList.workouts.filter({ $0.isSelected })
                        Text("Done(\(selectedWorkout.count))")
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
