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
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct WorkingOutView: View {
    @Bindable var store: StoreOf<WorkingOutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutReducer>
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var editMode: EditMode = .inactive
    @State private var myRoutine: MyRoutine

    @State var secondsElapsed = 0
    @State var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<WorkingOutReducer>,
         myRoutine: Binding<MyRoutine>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        self._myRoutine = .init(initialValue: myRoutine.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($myRoutine.routines) { routine in
                    WorkingOutSection(
                        routine: routine,
                        editMode: $editMode
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
            .navigationTitle(myRoutine.name)
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
                injected.appState[\.routing.homeView.workingOutView] = false
                
                store.send(.hideTabBar)
                store.send(.setTabBarOffset(offset: 0.0))
            }
            Button("Cancel") {
                restartTimer()
            }
            Button("OK") {
                injected.appState[\.routing.homeView.workingOutView] = false
                store.send(.hideTabBar)
                store.send(.setTabBarOffset(offset: 0.0))
                if !injected.interactors.routineInteractor.find(myRoutine: myRoutine) {
                    store.send(.saveRoutine(isSavedRoutine: true))
                }
                saveWorkoutRoutine(secondsElapsed)
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

private extension WorkingOutView {
    func saveWorkoutRoutine(_ routineTime: Int) {
        injected.interactors.routineInteractor.store(
            workoutRoutine: WorkoutRoutine(date: Date(),
                                           routineTime: routineTime,
                                           myRoutine: myRoutine)
        )
    }
}

//struct WorkingOutView_Previews: PreviewProvider {
//    @Environment(\.presentationMode) static var presentationmode
//    static var previews: some View {
//        WorkingOutView(myRoutine: .constant(MyRoutine.mockedData),
//                       isCloseWorking: .constant(false),
//                       hideTabValue: .constant(0.0),
//                       isSavedAlert: .constant(false))
//    }
//}
