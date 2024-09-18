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
    
    @State private var selectWorkouts: [Workout]
    @Binding var workoutsList: [Workout]
    @Binding var myRoutine: MyRoutine
    private var isMyWorkoutView: Bool = false
    
    init(store: StoreOf<WorkoutCategoryReducer>,
         workoutsList: [Workout],
         selectWorkouts: [Workout] = [],
         isMyWorkoutView: Bool = false,
         myRoutine: Binding<MyRoutine> = .init(projectedValue: .constant(MyRoutine(name: "", routines: [])))) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
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
                .uniqued()
            let categories = store.categories.filter {
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
        .onAppear {
            store.send(.getCategories)
        }
    }
}
