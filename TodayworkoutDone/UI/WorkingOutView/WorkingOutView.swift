//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct WorkingOutReducer {
    @ObservableState
    struct State: Equatable {
        var myRoutine: MyRoutine = MyRoutine(name: "",
                                             routines: [])
        var isHideTabBar = false
        var tabBarOffset: CGFloat = 0.0
        var isSavedRoutine = false
        var isSavedWorkout = false
    }
    
    enum Action {
        case hideTabBar
        case setTabBarOffset(offset: CGFloat)
        case saveRoutine(isSavedRoutine: Bool)
        case saveWorkout(isSavedWorkout: Bool)
        case save(secondsElapsed: Int)
    }
    
    @Dependency(\.workoutRoutineData) var context
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .save(let secondsElapsed):
                saveWorkoutRoutine(routine: state.myRoutine,
                                   routineTime: secondsElapsed)
                return .none
            default:
                return .none
            }
        }
    }
    
    func saveWorkoutRoutine(routine: MyRoutine, routineTime: Int) {
        do {
            try context.add(WorkoutRoutine(date: Date(),
                                       routineTime: routineTime,
                                       myRoutine: routine))
        } catch {
            print(WorkoutRoutineDatabase.WorkoutRoutineError.add)
        }
    }
}

struct WorkingOutView: View {
    @Bindable var store: StoreOf<WorkingOutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutReducer>
    
    @State private var editMode: EditMode = .inactive

    @State var secondsElapsed = 0
    @State var timer: Timer.TimerPublisher = Timer.publish(every: 1, 
                                                           on: .main,
                                                           in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<WorkingOutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(store.myRoutine.routines) { routine in
                    WorkingOutSection(
                        store: Store(
                            initialState: WorkingOutSectionReducer.State(
                                routine: routine,
                                editMode: editMode
                            )
                        ) {
                            WorkingOutSectionReducer()
                        }
                    )
                }
                Spacer().frame(height: 100)
            }
            .onAppear {
                self.instantiateTimer()
            }.onDisappear {
                self.cancelTimer()
            }.onReceive(timer) { _ in
                self.secondsElapsed += 1
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        store.send(.saveWorkout(isSavedWorkout: true))
                        cancelTimer()
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(secondsElapsed.secondToHMS)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
            .navigationTitle(store.myRoutine.name)
            .listStyle(.grouped)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .alert("워크아웃을 저장하겠습니까?",
               isPresented: viewStore.binding(
                get: { $0.isSavedWorkout },
                send: { WorkingOutReducer.Action.saveWorkout(isSavedWorkout: $0) }
               )
        ) {
            Button("Close") {
                store.send(.hideTabBar)
                store.send(.setTabBarOffset(offset: 0.0))
            }
            Button("Cancel") {
                restartTimer()
            }
            Button("OK") {
                store.send(.hideTabBar)
                store.send(.setTabBarOffset(offset: 0.0))
                store.send(.saveRoutine(isSavedRoutine: true))
                store.send(.save(secondsElapsed: secondsElapsed))
            }
        } message: {
            Text("새로운 워크아웃을 저장하시겟습니까")
        }
    }
    
    func instantiateTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
        self.connectedTimer = self.timer.connect()
        return
    }
    
    func cancelTimer() {
        self.connectedTimer?.cancel()
        return
    }
    
    func resetCounter() {
        self.secondsElapsed = 0
        return
    }
    
    func restartTimer() {
        self.cancelTimer()
        self.instantiateTimer()
        return
    }
}
