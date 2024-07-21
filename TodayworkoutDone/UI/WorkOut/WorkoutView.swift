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
        var workoutsList: [Workouts] = []
        var search = SearchReducer.State()
        var workoutCategory = WorkoutCategoryReducer.State()
    }
    
    enum Action {
        case search(SearchReducer.Action)
        case workoutCategory(WorkoutCategoryReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(.search(let keyword)):
                return .run { @MainActor send in
                    send(.workoutCategory(.setText(keyword: keyword)))
                }
            case .workoutCategory(.setText(let keyword)):
                state.workoutCategory.keyword = keyword
                return .none
            }
        }
    }
}

struct WorkoutView: View {
    @Bindable var store: StoreOf<WorkoutReducer>
    @Bindable var presentStore: StoreOf<WorkoutPresent>
    
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var workoutsList: Loadable<LazyList<Workouts>> = .notRequested
    @State private var routingState: Routing = .init()
    
    init(store: StoreOf<WorkoutReducer>,
         presentStore: StoreOf<WorkoutPresent>) {
        self.store = store
        self.presentStore = presentStore
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(store: store.scope(state: \.search, 
                                                 action: \.search))
                        .padding(.top, 10)
                    MyWorkoutView(workoutsList: $workoutsList)
                        .padding(.top, 10)
                    WorkoutCategoryView(
                        store: store.scope(state: \.workoutCategory,
                                           action: \.workoutCategory),
                        workoutsList: workoutsList,
                        selectWorkouts: injected.appState[\.userData].selectionWorkouts)
                    .inject(injected)
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
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onAppear {
            injected.appState[\.userData.selectionWorkouts].removeAll()
        }
    }
}

extension WorkoutView {
    func reloadWorkouts() {
        injected.interactors.workoutInteractor
            .load(workouts: $workoutsList)
    }
}

extension WorkoutView {
    struct Routing: Equatable {
        var workoutCategoryView: Bool = false
    }
}

private extension WorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutView)
    }
}


//struct WorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutView(store: Store(initialState: WorkoutReducer.State()) {
//            WorkoutReducer()
//        })
//        .background(Color.gray)
//    }
//}
