//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
struct HomeReducer {
    enum Tab { 
        case workout
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        var routineName = ""
        var isHideTabBar = false
        var tabBarOffset: CGFloat = 0.0
        var bottomEdge: CGFloat = 35
        
        var workingOut = WorkingOutReducer.State()
        var tabBar: CustomTabBarReducer.State
        var calendar: CalendarReducer.State = CalendarReducer.State()
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case startButtonTapped
        
        case enterRoutineName(name: String)
        case setTabBarOffset(offset: CGFloat)
        
        case setDestination(Destination.State)
        
        case workingOut(WorkingOutReducer.Action)
        case tabBar(CustomTabBarReducer.Action)
        case calendar(CalendarReducer.Action)
        
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
            case tappedMyRoutineAlerOk(MyRoutineState?)
        }
    }
    
    @Dependency(\.myRoutineData) var myRoutineContext
    
    var body: some Reducer<State, Action> {
        Scope(state: \.workingOut, action: \.workingOut) {
            WorkingOutReducer()
        }
        Scope(state: \.calendar, action: \.calendar) {
            CalendarReducer()
        }
        Reduce { state, action in
            switch action {
            case .enterRoutineName(let name):
                state.routineName = name
                return .none
                
            case .startButtonTapped:
                state.destination = .workoutView(WorkoutReducer.State(myRoutine: MyRoutineState()))
                return .none
                
            case .setTabBarOffset(let offset):
                state.tabBarOffset = offset
                return .none
                
            case .setDestination(let detination):
                state.destination = detination
                return .none

            case let .destination(.presented(.alert(.tappedMyRoutineAlerOk(myRoutine)))):
                return .run { send in
                    if var myRoutine = myRoutine {
                        for i in 0..<myRoutine.routines.count {
                            for j in 0..<myRoutine.routines[i].sets.count {
                                myRoutine.routines[i].sets[j].isChecked = false
                            }
                        }
                        try myRoutineContext.add(myRoutine.toModel())
                        try myRoutineContext.save()
                    } else {
                        throw MyRoutineDatabase.MyRoutineError.add
                    }
                }
            case .destination(.presented(.alert(.tappedMyRoutineAlertCancel))):
                return .none

            case .destination(.presented(.workoutView(.destination(.presented(.makeWorkoutView(.tappedDone(let myRoutine))))))),
                    .destination(.presented(.workoutView(.workoutCategory(.workoutList(.element(_, .destination(.presented(.makeWorkoutView(.tappedDone(let myRoutine)))))))))),
                    .destination(.presented(.workoutView(.tappedDone(let myRoutine)))):
                @Dependency(\.routineData.fetch) var fetch
                state.workingOut.myRoutine = myRoutine
                for (routineIndex, routine) in myRoutine.routines.enumerated() {
                    var descriptor = FetchDescriptor<Routine>(
                        predicate: #Predicate {
                            $0.workout.name == routine.workout.name
                        },
                        sortBy: [SortDescriptor(\.endDate, order: .forward)]
                    )
                    descriptor.fetchLimit = 1
                    for (setIndex, _) in routine.sets.enumerated() {
                        do {
                            if let prevRoutine = try fetch(descriptor).first,
                               let prevWeight = prevRoutine.sets.first(where: { $0.order == setIndex + 1 })?.weight,
                               let prevReps = prevRoutine.sets.first(where: { $0.order == setIndex + 1 })?.reps {
                                state.workingOut.myRoutine?.routines[routineIndex]
                                    .sets[setIndex].prevWeight = prevWeight
                                state.workingOut.myRoutine?.routines[routineIndex]
                                    .sets[setIndex].prevReps = prevReps
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                state.workingOut.isEdit = false
                state.workingOut.workingOutSection = IdentifiedArrayOf(
                    uniqueElements: state.workingOut.myRoutine?.routines.map {
                        WorkingOutSectionReducer.State(
                            routine: $0,
                            editMode: .inactive
                        )
                    } ?? []
                )

                return .none

            case .destination:
              return .none
                
            case .tabBar(.tabButton(.setTab(let info))):
                if state.tabBar.tabButton.info.index != info.index {
                    state.tabBar.tabButton.info = info
                }
                return .none
                
            case let .workingOut(.presentedSaveRoutineAlert(myRoutine)):
                if let routine = myRoutine {
                    return .run { send in
                        let myRoutines = try myRoutineContext.fetchAll()
                            .compactMap { $0.name }
                        if myRoutines.contains(routine.name) == false {
                            await send(.setDestination(.alert(.saveRoutineAlert(routine))))
                        }
                    }
                } else {
                    return .none
                }
            case .workingOut(.destination(.presented(.alert(.tappedWorkoutAlertClose)))):
                state.isHideTabBar = true
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                }
            case .workingOut(.destination(.presented(.alert(.tappedWorkoutAlertOk(_))))):
                state.isHideTabBar = true
                return .run { send in
                    await send(.setTabBarOffset(offset: 0.0))
                }

            case .workingOut(_):
                return .none
            case .calendar:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    @ObservedObject var viewStore: ViewStoreOf<HomeReducer>

    @State private var isShowingDummyView = false
    
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
                    if viewStore.workingOut.myRoutine == nil {
                        startButton()
                    }
                }
                .tag(0)
                
                CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
                .tag(1)
            }
            if viewStore.workingOut.myRoutine != nil {
                SlideOverCardView(
                    hideTabValue: viewStore.binding(
                        get: { $0.tabBarOffset },
                        send: { HomeReducer.Action.setTabBarOffset(offset: $0) }
                    ),
                    content: {
                        WorkingOutView(store: store.scope(state: \.workingOut,
                                                          action: \.workingOut))
                    }
                )
            }
//            VStack {
//                HStack {
//                    Spacer()
//                    FloatingButton {
//                        isShowingDummyView.toggle()
//                    }
//                    .padding()
//                }
//                Spacer()
//            }
        }
        .sheet(isPresented: $isShowingDummyView) {
            HealthKitDummyView()
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
        .tint(.black)
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
                    .background(Color.personal)
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
    static func saveRoutineAlert(_ runningMyRoutine: MyRoutineState?) -> Self {
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
}
