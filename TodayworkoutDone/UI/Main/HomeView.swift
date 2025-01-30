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
        @Shared var myRoutine: MyRoutine
        
        var routineName = ""
        var isHideTabBar = false
        var tabBarOffset: CGFloat = 0.0
        var bottomEdge: CGFloat = 35
        var deletedSectionIndex: Int?
        
        var workingOut: WorkingOutReducer.State?
        var tabBar: CustomTabBarReducer.State = CustomTabBarReducer.State(
            bottomEdge: 35,
            tabButton: TabButtonReducer.State(
                info: TabButtonReducer.TabInfo(imageName: "dumbbell.fill",
                                               index: 0)
            )
        )
        var calendar: CalendarReducer.State = CalendarReducer.State()
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case startButtonTapped
        
        case enterRoutineName(name: String)
        case setTabBarOffset(offset: CGFloat)
        case presentedSaveRoutineAlert
        
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
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            print(action.description)
            switch action {
            case .enterRoutineName(let name):
                state.routineName = name
                return .none
                
            case .startButtonTapped:
                state.destination = .workoutView(
                    WorkoutReducer.State(
                        myRoutine: Shared(state.myRoutine),
                        workoutCategory: WorkoutCategoryReducer.State(
                            myRoutine: Shared(state.myRoutine),
                            workoutList: WorkoutListReducer.State(
                                myRoutine: Shared(state.myRoutine)
                            )
                        )
                    )
                )
                return .none
                
            case .setTabBarOffset(let offset):
                state.tabBarOffset = offset
                return .none
                
            case .presentedSaveRoutineAlert:
                state.destination = .alert(.saveRoutineAlert(state.myRoutine))
                return .none

            case .destination(.presented(.alert(.tappedWorkoutAlertClose))):
                state.isHideTabBar = true
                state.myRoutine.isRunning = false
                state.destination = .none
                state.workingOut = nil
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
                state.myRoutine.isRunning = false
                state.destination = .none
                state.workingOut = nil
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                    await send(.presentedSaveRoutineAlert)
                }
                
            case .destination(.presented(.alert(.tappedMyRoutineAlertCancel))):
                return .none
                
            case .destination(.presented(.alert(.tappedMyRoutineAlerOk(let myRoutine)))):
                insertMyRoutine(myRoutine: myRoutine)
                return .none
                
            case .destination(.presented(.workoutView(.makeWorkout(.tappedDone)))):
                if state.myRoutine.isRunning {
                    state.workingOut = WorkingOutReducer.State(
                        myRoutine: Shared(state.myRoutine),
                        workingOutSection: IdentifiedArrayOf(
                            uniqueElements: state.myRoutine.routines.map {
                                WorkingOutSectionReducer.State(
                                    routine: $0,
                                    editMode: .inactive
                                )
                            }
                        )
                    )
                }
                return .none
                
            case .destination:
              return .none

            // MARK: - workingOut
            case .workingOut(let action):
                switch action {
                case .tappedToolbarCloseButton(let secondsElapsed):
                    state.destination = .alert(.saveWorkoutAlert(secondsElapsed))
                    return .none
                case .tappedEdit:
                    return .run { [workingOutSection = state.workingOut?.workingOutSection] send in
                        if let sections = workingOutSection {
                            for section in sections {
                                let editMode: EditMode = section.editMode == .inactive ? .active : .inactive
                                await send(.workingOut(.workingOutSection(.element(id: section.id, action: .setEditMode(editMode)))))
                            }
                        }
                    }
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
                    
                case let .workingOutSection(action):
                    switch action {
                    case let .element(sectionId, action):
                        switch action {
                        case .tappedAddFooter:
                            if let sectionIndex = state.workingOut?
                                .workingOutSection
                                .index(id: sectionId) {
                                let workoutSet = WorkoutSet()
                                state.workingOut?
                                    .workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .append(
                                        WorkingOutRowReducer.State(workoutSet: workoutSet,
                                                                   editMode: .active)
                                    )
                                state.workingOut?.myRoutine
                                    .routines[sectionIndex]
                                    .sets
                                    .append(workoutSet)
                            }
                            return .none
                        case let .workingOutRow(action):
                            switch action {
                            case let .element(rowId, action):
                                switch action {
                                case let .toggleCheck(isChecked):
                                    if let sectionIndex = state.workingOut?
                                        .workingOutSection
                                        .index(id: sectionId),
                                       let rowIndex = state.workingOut?
                                        .workingOutSection[sectionIndex]
                                        .workingOutRow
                                        .index(id: rowId) {
                                        state.workingOut?.myRoutine
                                            .routines[sectionIndex]
                                            .sets[rowIndex]
                                            .isChecked = isChecked
                                        state.workingOut?
                                            .workingOutSection[sectionIndex]
                                            .workingOutRow[rowIndex]
                                            .isChecked = isChecked
                                    }
                                    return .none
                                case let .typeLab(lab):
                                    if let sectionIndex = state.workingOut?
                                        .workingOutSection
                                        .index(id: sectionId),
                                       let rowIndex = state.workingOut?
                                        .workingOutSection[sectionIndex]
                                        .workingOutRow
                                        .index(id: rowId),
                                       let labValue = Int(lab) {
                                        state.workingOut?.myRoutine
                                            .routines[sectionIndex]
                                            .sets[rowIndex]
                                            .lab = labValue
                                    }
                                    return .none
                                case let .typeWeight(weight):
                                    if let sectionIndex = state.workingOut?
                                        .workingOutSection
                                        .index(id: sectionId),
                                       let rowIndex = state.workingOut?
                                        .workingOutSection[sectionIndex]
                                        .workingOutRow
                                        .index(id: rowId),
                                       let weightValue = Double(weight) {
                                        state.workingOut?.myRoutine
                                            .routines[sectionIndex]
                                            .sets[rowIndex]
                                            .weight = weightValue
                                    }
                                    return .none
                                }
                            }
                        case .setEditMode(let editMode):
                            if let sections = state.workingOut?.workingOutSection {
                                for index in sections.indices {
                                    state.workingOut?.workingOutSection[index].editMode = editMode
                                    if let rows = state.workingOut?.workingOutSection[index].workingOutRow {
                                        for rowIndex in rows.indices {
                                            state.workingOut?.workingOutSection[index].workingOutRow[rowIndex].editMode = editMode
                                        }
                                    }
                                }
                            }
                            return .none
                        case .workingOutHeader:
                            return .none
                        }
                    }
                }
                
            case .tabBar(.tabButton(.setTab(let info))):
                if state.tabBar.tabButton.info.index != info.index {
                    state.tabBar.tabButton.info = info
                }
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
            try context.save()
        } catch {
            print(WorkoutRoutineDatabase.WorkoutRoutineError.add)
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
                    MainView(bottomEdge: store.bottomEdge)
                    if store.myRoutine.isRunning == false {
                        startButton()
                    }
                }
                .tag(0)
                
                CalendarView(store: Store(initialState: CalendarReducer.State()) {
                    CalendarReducer()
                })
                .tag(1)
            }
            if let store = store.scope(state: \.workingOut,
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
            Spacer()
        }
        .overlay(
            VStack {
                CustomTabBar(store: store.scope(state: \.tabBar,
                                                action: \.tabBar))
            }.offset(y: store.isHideTabBar ? CGFloat.zero : store.tabBarOffset),
            alignment: .bottom
        )
        .fullScreenCover(
            item: $store.scope(state: \.destination?.workoutView,
                               action: \.destination.workoutView)
        ) { store in
            WorkoutView(store: store)
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
