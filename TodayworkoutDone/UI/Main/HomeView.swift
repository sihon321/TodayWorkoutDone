//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct HomeReducer {
    enum Tab { 
        case workout
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        var bottomEdge: CGFloat
        var routineName = ""
        var workouts: [Workout] = []
        var isHideTabBar = false
        var tabBarOffset: CGFloat = 0.0
        var myRoutine: MyRoutine?
        
        var workout: WorkoutReducer.State?
        var workingOut: WorkingOutReducer.State?
        var tabBar: CustomTabBarReducer.State
        
        init(bottomEdge: CGFloat) {
            self.bottomEdge = bottomEdge
            tabBar = CustomTabBarReducer.State(
                bottomEdge: bottomEdge,
                tabButton: TabButtonReducer.State(
                    info: TabButtonReducer.TabInfo(imageName: "dumbbell.fill",
                                                   index: 0)
                )
            )
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case startButtonTapped
        
        case enterRoutineName(name: String)
        case setTabBarOffset(offset: CGFloat)
        case presentedSaveRoutineAlert
        
        case workout(WorkoutReducer.Action)
        case workingOut(WorkingOutReducer.Action)
        case tabBar(CustomTabBarReducer.Action)
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case workoutView(WorkoutReducer)
        case alert(AlertState<Alert>)
        
        enum Alert: Equatable {
            case tappedMyRoutineAlertCancel
            case tappedMyRoutineAlerOk(MyRoutine?)
            
            case tappedWorkoutAlertClose
            case tappedWorkoutAlertCancel
            case tappedWorkoutAlertOk(secondsElapsed: Int)
        }
    }
    
    private enum CancelID { case timer }
    
    @Dependency(\.myRoutineData) var context
    @Dependency(\.categoryAPI) var categoryRepository
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            print(action.description)
            switch action {
            case .enterRoutineName(let name):
                state.routineName = name
                return .none
            case .startButtonTapped:
                state.workout = WorkoutReducer.State()
                if let workoutState = state.workout {
                    state.destination = .workoutView(workoutState)
                }
                return .none
            case .setTabBarOffset(let offset):
                state.tabBarOffset = offset
                return .none
            case .presentedSaveRoutineAlert:
                state.destination = .alert(.saveRoutineAlert(state.workout?.myRoutine))
                return .none

            case .destination(.presented(.alert(.tappedWorkoutAlertClose))):
                state.isHideTabBar = true
                state.myRoutine = nil
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                }
            case .destination(.presented(.alert(.tappedWorkoutAlertCancel))):
                return .run { send in
                    await send(.workingOut(.toggleTimer))
                }
            case .destination(.presented(.alert(.tappedWorkoutAlertOk(let secondsElapsed)))):
                saveWorkoutRoutine(myRoutine: state.workingOut?.myRoutine,
                                   routineTime: secondsElapsed)
                state.isHideTabBar = true
                state.myRoutine = nil
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                    await send(.presentedSaveRoutineAlert)
                }
            case .destination(.presented(.alert(.tappedMyRoutineAlertCancel))):
                return .none
            case .destination(.presented(.alert(.tappedMyRoutineAlerOk(let myRoutine)))):
                saveMyRoutine(myRoutine: myRoutine)
                return .none
            case .destination:
              return .none
                
            // MARK: - workout
            case .workout(let action):
                switch action {
                case .search(let keyword):
                    state.workout?.keyword = keyword
                    return .none
                case .dismiss:
                    state.destination = .none
                    return .none
                case .hasLoaded:
                    state.workout?.hasLoaded = true
                    return .none
                case .filterWorkout:
                    do {
                        let routines = state.workout?.workouts
                            .filter({ $0.isSelected })
                            .compactMap({
                                return Routine(workouts: $0)
                            })
                        let myRoutine = MyRoutine(
                            name: "",
                            routines: routines ?? []
                        )
                        try context.add(myRoutine)
                        return .run { @MainActor send in
                            send(.workout(.appearMakeWorkoutView(myRoutine)))
                        }
                    } catch {
                        print(error.localizedDescription)
                        return .none
                    }
                case .appearMakeWorkoutView(let myRoutine):
                    if let myRoutine = myRoutine {
                        state.workout?.makeWorkout = .init(myRoutine: myRoutine)
                        if let makeWorkoutState = state.workout?.makeWorkout {
                            state.workout?.destination = .makeWorkoutView(makeWorkoutState)
                        }
                    }
                    return .none
                case .getMyRoutines:
                    return .run { send in
                        let myRoutines = try context.fetchAll()
                        await send(.workout(.fetchMyRoutines(myRoutines)))
                    }
                case .fetchMyRoutines(let myRoutines):
                    state.workout?.myRoutineState.myRoutines = myRoutines
                    return .none
                case .destination(.presented(.alert(.tappedMyRoutineStart(let myRoutine)))):
                    return .send(.workout(.makeWorkout(.tappedDone(myRoutine))))
                case .destination:
                    return .none
                    
                // MARK: - workoutCategory
                case .workoutCategory(let action):
                    switch action {
                    case .setText(let keyword):
                        state.workout?.workoutCategory.keyword = keyword
                        return .none
                    case .getCategories:
                        return .run { send in
                            let categories = categoryRepository.loadCategories()
                            await send(.workout(.workoutCategory(.updateCategories(categories))))
                        }
                    case .updateCategories(let categories):
                        state.workout?.workoutCategory.categories = categories
                        return .none
                        
                    // MARK: - workoutList
                    case .workoutList(let action):
                        switch action {
                        case .getWorkouts:
                            return .run { send in
                                let workouts = workoutRepository.loadWorkouts()
                                await send(.workout(.workoutCategory(.workoutList(.updateWorkouts(workouts)))))
                            }
                        case .updateWorkouts(let workouts):
                            state.workout?.workouts = workouts
                            state.workout?.workoutCategory.workoutList.workouts = workouts
                            return .none
                        case .makeWorkoutView:
                            return .send(.workout(.filterWorkout))
                        }
                    }
                    
                // MARK: - makeWorkout
                case .makeWorkout(let action):
                    switch action {
                    case .dismiss:
                        state.workout?.destination = .none
                        return .none
                    case .tappedDone(let myRoutine):
                        state.workout?.destination = .none
                        state.destination = .none
                        state.myRoutine = myRoutine
                        state.workingOut = WorkingOutReducer.State(
                            myRoutine: myRoutine
                        )
                        return .none
                    }
                    
                // MARK: - myRoutine
                case .myRoutineAction(let action):
                    switch action {
                    case .touchedMyRoutine(let selectedMyRoutine):
                        state.workout?.destination = .alert(.startMyRoutine(selectedMyRoutine))
                        return .none
                    case .touchedEditMode(let myRoutine):
                        return .send(.workout(.appearMakeWorkoutView(myRoutine)))
                    }
                }
                
            // MARK: - workingOut
            case .workingOut(let action):
                switch action {
                case .tappedToolbarCloseButton(let secondsElapsed):
                    state.destination = .alert(.saveWorkoutAlert(secondsElapsed))
                    return .none
                case .cancelTimer:
                    return .cancel(id: CancelID.timer)
                    
                case .resetTimer:
                    state.workingOut?.secondsElapsed = 0
                    return .none
                case .timerTicked:
                    state.workingOut?.secondsElapsed += 1
                    return .none
                case .toggleTimer:
                    state.workingOut?.isTimerActive.toggle()
                    return .run { [isTimerActive = state.workingOut?.isTimerActive] send in
                      guard let isTimerActive = isTimerActive, isTimerActive else { return }
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                          await send(.workingOut(.timerTicked), animation: .default)
                      }
                    }
                    .cancellable(id: CancelID.timer, cancelInFlight: true)
                }
                
            case .tabBar(.tabButton(.setTab(let info))):
                state.tabBar.tabButton.info = info
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
          Destination.body
        }
    }
    
    func saveMyRoutine(myRoutine: MyRoutine?) {
        do {
            if let myRoutine = myRoutine {
                try context.add(myRoutine)
            } else {
                throw MyRoutineDatabase.MyRoutineError.add
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveWorkoutRoutine(myRoutine: MyRoutine?, routineTime: Int) {
        guard let myRoutine = myRoutine else {
            return
        }
        @Dependency(\.workoutRoutineData) var context
        
        do {
            let workoutRoutine = WorkoutRoutine(date: Date(),
                                                routineTime: routineTime,
                                                myRoutine: myRoutine)
            try context.add(workoutRoutine)
        } catch {
            print(WorkoutRoutineDatabase.WorkoutRoutineError.add)
        }
    }
}

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    @ObservedObject var viewStore: ViewStoreOf<HomeReducer>

    init(store: StoreOf<HomeReducer>) {
        UITabBar.appearance().isHidden = true
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ZStack {
            TabView(
                selection: viewStore.binding(
                    get: { $0.tabBar.tabButton.info },
                    send: { HomeReducer.Action.tabBar(.tabButton(.setTab(info: $0))) }
                ).index
            ) {
                ZStack {
                    MainView(bottomEdge: store.state.bottomEdge)
                    if store.state.myRoutine == nil {
                        startButton()
                    } else if let store = store.scope(state: \.workingOut,
                                                       action: \.workingOut) {
                        SlideOverCardView(
                            hideTabValue: viewStore.binding(
                                get: { $0.tabBarOffset },
                                send: { HomeReducer.Action.setTabBarOffset(offset: $0) }
                            ),
                            content: {
                                WorkingOutView(store: store)
                            }
                        )
                    }
                }
                .tag(0)
                
                CalendarView()
                    .tag(1)
            }
            .overlay(
                VStack {
                    CustomTabBar(store: store.scope(state: \.tabBar,
                                                    action: \.tabBar))
                }.offset(y: store.state.isHideTabBar ? CGFloat.zero : store.state.tabBarOffset),
                alignment: .bottom
            )
            Spacer()
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.workoutView,
                               action: \.destination.workoutView)
        ) { _ in
            if let store = self.store.scope(state: \.workout,
                                            action: \.workout) {
                WorkoutView(store: store)
            }
        }
        .alert($store.scope(state: \.destination?.alert,
                            action: \.destination.alert))
    }
}

extension HomeView {
    func startButton() -> some View {
        VStack {
            Spacer()
            Button(action: {
                viewStore.send(.startButtonTapped)
            }) {
                Text("워크아웃 시작")
                    .frame(minWidth: 0, maxWidth: .infinity - 30)
                    .padding([.top, .bottom], 5)
                    .background(Color(0xfeb548))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0,
                                                style: .continuous))
            }
            .padding(.horizontal, 30)
            .offset(y: -50)
        }

    }
}

extension AlertState where Action == HomeReducer.Destination.Alert {
    static func saveRoutineAlert(_ runningMyRoutine: MyRoutine?) -> Self {
        Self {
            TextState("루틴 저장")
        } actions: {
            ButtonState(action: .tappedMyRoutineAlerOk(runningMyRoutine)) {
                TextState("OK")
            }
            ButtonState() {
                TextState("Cancel")
            }
        } message: {
            TextState("새로운 루틴을 저장하시겟습니까")
        }
    }
    
    static func saveWorkoutAlert(_ secondsElapsed: Int) -> Self {
        Self {
            TextState("워크아웃 저장")
        } actions: {
            ButtonState(action: .tappedWorkoutAlertClose) {
                TextState("Close")
            }
            ButtonState(action: .tappedWorkoutAlertCancel) {
                TextState("Cancel")
            }
            ButtonState(action: .tappedWorkoutAlertOk(secondsElapsed: secondsElapsed)) {
                TextState("Ok")
            }
        } message: {
            TextState("새로운 워크아웃을 저장하시겟습니까?")
        }
    }
}
