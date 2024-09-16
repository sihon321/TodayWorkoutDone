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
struct WorkoutCategoryReducer {
    @ObservableState
    struct State: Equatable {
        var keyword: String = ""
    }
    
    enum Action {
        case setText(keyword: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setText(_):
                return .none
            }
        }
    }
}

struct WorkoutCategoryView: View {
    @Bindable var store: StoreOf<WorkoutCategoryReducer>

    @State private var selectWorkouts: [Workout]
    @State private(set) var categories: [Category]
    
    @Binding var workoutsList: [Workout]

    @Binding var myRoutine: MyRoutine
    private var isMyWorkoutView: Bool = false
    
    init(store: StoreOf<WorkoutCategoryReducer>,
         categories: [Category],
         workoutsList: [Workout],
         selectWorkouts: [Workout] = [],
         isMyWorkoutView: Bool = false,
         myRoutine: Binding<MyRoutine> = .init(projectedValue: .constant(MyRoutine(name: "", routines: [])))) {
        self.store = store
        self._categories = .init(initialValue: categories)
        self._workoutsList = .init(projectedValue: .constant(workoutsList))
        self._selectWorkouts = .init(initialValue: selectWorkouts)
        self.isMyWorkoutView = isMyWorkoutView
        self._myRoutine = myRoutine
    }
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            let filteredCategory = workoutsList
                .filter({ $0.name.hasPrefix(store.keyword) })
                .compactMap({ $0.category })
                .uniqued() ?? []
            let categories = categories.filter {
                if filteredCategory.isEmpty {
                    return true
                } else if filteredCategory.contains($0.name) {
                    return true
                } else {
                    return false
                }
            } ?? []
            ForEach(categories) { category in
                NavigationLink {
                    WorkoutListView(workoutsList: workoutsList,
                                    selectWorkouts: selectWorkouts,
                                    category: category,
                                    isMyWorkoutView: isMyWorkoutView,
                                    myRoutine: $myRoutine)
                } label: {
                    WorkoutCategorySubview(category: category.name)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectWorkouts.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !isMyWorkoutView {
                            
                        } else {
                            myRoutine.routines += selectWorkouts.compactMap({ Routine(workouts: $0) })
//                            injected.appState[\.userData.selectionWorkouts].removeAll()
//                            injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                        }
                    }) {
                        Text("Done(\(selectWorkouts.count))")
                    }
                    .fullScreenCover(isPresented: .constant(false),
                                     content: {
                        if !isMyWorkoutView {
                            MakeWorkoutView(
                                myRoutine: .constant(MyRoutine(name: "",
                                                               routines: selectWorkouts.compactMap({ Routine(workouts: $0) })))
                            )
                        }
                    })
                }
            }
            if isMyWorkoutView {
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
    }
}

// MARK: - Side Effects

private extension WorkoutCategoryView {
    func reloadCategory() {
//        injected.interactors.categoryInteractor
//            .load(categories: $categories)
    }
}

extension WorkoutCategoryView {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
        var workoutListView: Bool = false
    }
}
