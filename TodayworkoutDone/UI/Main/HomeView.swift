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
        var categories: Categories = []
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
                state.workout = WorkoutReducer.State(state.myRoutine)
                if let workoutState = state.workout {
                    state.destination = .workoutView(workoutState)
                }
                return .none
            case .setTabBarOffset(let offset):
                state.tabBarOffset = offset
                return .none
            case .presentedSaveRoutineAlert:
                state.destination = .alert(.saveRoutineAlert(state.myRoutine))
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
                insertWorkoutRoutine(myRoutine: state.workingOut?.myRoutine,
                                   routineTime: secondsElapsed)
                state.isHideTabBar = true
                state.myRoutine = nil
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                    await send(.presentedSaveRoutineAlert)
                }
            case .destination(.presented(.alert(.tappedMyRoutineAlertCancel))):
                state.myRoutine = nil
                return .none
            case .destination(.presented(.alert(.tappedMyRoutineAlerOk(let myRoutine)))):
                insertMyRoutine(myRoutine: myRoutine)
                state.myRoutine = nil
                return .none
            case .destination:
              return .none
                
            // MARK: - workout
            case .workout(let action):
                switch action {
                case .search(let keyword):
                    state.workout?.workoutCategory.keyword = keyword
                    return .none
                case .dismiss:
                    state.destination = .none
                    return .none
                case .hasLoaded:
                    state.workout?.hasLoaded = true
                    return .none
                case .filterWorkout:
                    let routines = state.workout?.workouts
                        .filter({ $0.isSelected })
                        .compactMap({
                            return Routine(workouts: $0)
                        })
                    let myRoutine = MyRoutine(
                        name: "",
                        routines: routines ?? []
                    )
                    return .run { @MainActor send in
                        send(.workout(.appearMakeWorkoutView(myRoutine, false)))
                    }
                case .appearMakeWorkoutView(let myRoutine, let isEditMode):
                    if let myRoutine = myRoutine {
                        state.workout?.makeWorkout = .init(myRoutine: myRoutine,
                                                           editMode: isEditMode ? .active : .inactive)
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
                    case .save(let myRoutine):
                        saveMyRoutine()
                        return .send(.workout(.makeWorkout(.dismiss(myRoutine))))
                    case .didUpdateText(let text):
                        state.workout?.makeWorkout?.myRoutine.name = text
                        return .none
                    case .tappedAdd:
                        if let workoutCategory = state.workout?.makeWorkout?.addWorkoutCategory {
                            state.workout?.makeWorkout?.destination = .addWorkoutCategory(workoutCategory)
                        }
                        return .none
                    case .destination(.presented(.addWorkoutCategory(let action))):
                        return .send(.workout(.makeWorkout(.addWorkoutCategory(action))))
                    case .destination:
                        return .none
                        
                    // MARK: - addmakeWorkout
                    case .addWorkoutCategory(let action):
                        switch action {
                        case .getCategories:
                            return .run { send in
                                let categories = categoryRepository.loadCategories()
                                await send(.workout(.makeWorkout(.addWorkoutCategory(.updateCategories(categories)))))
                            }
                        case .updateCategories(let categories):
                            state.workout?.makeWorkout?.addWorkoutCategory.categories = categories
                            return .send(.workout(.makeWorkout(.addWorkoutCategory(.workoutList(.getWorkouts)))))
                        case .dismissWorkoutCategory:
                            state.workout?.makeWorkout?.destination = .none
                            return .none
                            
                            // MARK: - addmakeWorkout workoutList
                        case .workoutList(let action):
                            switch action {
                            case .getWorkouts:
                                return .run { send in
                                    let workouts = workoutRepository.loadWorkouts()
                                    await send(.workout(.makeWorkout(.addWorkoutCategory(.workoutList(.updateWorkouts(workouts))))))
                                }
                            case .updateWorkouts(let workouts):
                                if let myWorkout = state.workout?.makeWorkout?.addWorkoutCategory.workoutList.myRoutine?.routines.compactMap({ $0.workout }) {
                                    let myWorkoutIDs = Set(myWorkout.map { $0.id }) // Set을 사용해 성능 최적화
                                    state.workout?.makeWorkout?.addWorkoutCategory.workoutList.workouts = workouts.map { workout in
                                        let modifiedWorkout = workout
                                        modifiedWorkout.isSelected = myWorkoutIDs.contains(workout.id)
                                        return modifiedWorkout
                                    }
                                }

                                return .none
                            case .makeWorkoutView(let routines):
                                state.workout?.makeWorkout?.destination = .none
                                
                                for routine in routines {
                                    if let elements = state.workout?.makeWorkout?
                                        .workingOutSection.elements.map({ $0.routine.workout.name }),
                                       elements.contains(routine.workout.name) == false {
                                        state.workout?.makeWorkout?
                                            .workingOutSection
                                            .append(
                                                WorkingOutSectionReducer.State(
                                                    routine: routine,
                                                    editMode: .inactive
                                                )
                                            )
                                    }
                                }
                                state.workout?.makeWorkout?.myRoutine.routines = routines
                                return .none
                            }
                        }
                    case let .workingOutSection(action):
                        switch action {
                        case let .element(id, action):
                            switch action {
                            case .tappedAddFooter:
                                if let index = state.workout?.makeWorkout?
                                    .workingOutSection
                                    .index(id: id) {
                                    state.workout?.makeWorkout?
                                        .workingOutSection[index]
                                        .workingOutRow
                                        .append(
                                            WorkingOutRowReducer.State()
                                        )
                                }
                                return .none
                            case .workingOutRow:
                                return .none
                            }
                        }
                    }
                    
                // MARK: - myRoutine
                case .myRoutineAction(let action):
                    switch action {
                    case .touchedMyRoutine(let selectedMyRoutine):
                        state.workout?.destination = .alert(.startMyRoutine(selectedMyRoutine))
                        return .none
                    case .touchedEditMode(let myRoutine):
                        if let myRoutine = state.workout?.refetch(myRoutine) {
                            return .send(.workout(.appearMakeWorkoutView(myRoutine, true)))
                        }
                        return .none
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
                case .workingOutSection(_):
                    return .none
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
    
    private func insertMyRoutine(myRoutine: MyRoutine?) {
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
    
    private func insertWorkoutRoutine(myRoutine: MyRoutine?, routineTime: Int) {
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
    
    private func saveMyRoutine() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteMyRoutine(_ myRoutine: MyRoutine) {
        do {
            try context.delete(myRoutine)
        } catch {
            print(error.localizedDescription)
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
                
                CalendarView(store: Store(initialState: CalendarReducer.State()) {
                    CalendarReducer()
                })
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
