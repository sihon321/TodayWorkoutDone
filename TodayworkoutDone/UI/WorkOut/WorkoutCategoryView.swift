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
    
    @Environment(\.injected) private var injected: DIContainer

    @State private var routingState: Routing = .init()
    @State private var selectWorkouts: [Workouts]
    @State private(set) var categories: Loadable<LazyList<Category>>
    
    @Binding var workoutsList: Loadable<LazyList<Workouts>>

    @Binding var myRoutine: MyRoutine
    private var isMyWorkoutView: Bool = false
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    init(store: StoreOf<WorkoutCategoryReducer>,
         categories: Loadable<LazyList<Category>> = .notRequested,
         workoutsList: Loadable<LazyList<Workouts>>,
         selectWorkouts: [Workouts] = [],
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
            let filteredCategory = workoutsList.value?.array()
                .filter({ $0.name.hasPrefix(store.keyword) })
                .compactMap({ $0.category })
                .uniqued() ?? []
            let categories = categories.value?.array().filter {
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
                    .inject(injected)
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
                            injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = true
                        } else {
                            myRoutine.routines += selectWorkouts.compactMap({ Routine(workouts: $0) })
                            injected.appState[\.userData.selectionWorkouts].removeAll()
                            injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                        }
                    }) {
                        Text("Done(\(selectWorkouts.count))")
                    }
                    .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
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
                        injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            }
        }
        .onAppear(perform: reloadCategory)
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onReceive(workoutsUpdate) { self.selectWorkouts = $0 }
    }
}

// MARK: - Side Effects

private extension WorkoutCategoryView {
    func reloadCategory() {
        injected.interactors.categoryInteractor
            .load(categories: $categories)
    }
}

extension WorkoutCategoryView {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
        var workoutListView: Bool = false
    }
}

private extension WorkoutCategoryView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutCategoryView)
    }
    
    var workoutsUpdate: AnyPublisher<[Workouts], Never> {
        injected.appState.updates(for: \.userData.selectionWorkouts)
    }
}

//struct WorkoutCategoryView_Previews: PreviewProvider {
//    @Environment(\.presentationMode) static var presentationmode
//    static var previews: some View {
//        WorkoutCategoryView(categories: .loaded(Category.mockedData.lazyList), 
//                            workoutsList: .loaded(Workouts.mockedData.lazyList),
//                            selectWorkouts: [],
//                            search: .constant(""))
//            .inject(.preview)
//    }
//}
