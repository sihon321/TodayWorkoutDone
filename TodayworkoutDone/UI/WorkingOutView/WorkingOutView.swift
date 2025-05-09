//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var myRoutine: MyRoutineState?
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State> = []
        
        var secondsElapsed = 0
        var isTimerActive = false
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case tappedToolbarCloseButton(secondsElapsed: Int)
        case tappedEdit
        
        case cancelTimer
        case resetTimer
        case timerTicked
        case toggleTimer
        
        case presentedSaveRoutineAlert(MyRoutineState?)
        
        indirect case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Alert>)
        
        enum Alert: Equatable {
            case tappedWorkoutAlertClose
            case tappedWorkoutAlertCancel
            case tappedWorkoutAlertOk(secondsElapsed: Int)
        }
    }
    
    private enum CancelID { case timer }
    @Dependency(\.continuousClock) var clock
    @Dependency(\.myRoutineData) var myRoutineContext
    @Dependency(\.workoutRoutineData) var workoutRoutineContext

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cancelTimer:
                return .cancel(id: CancelID.timer)
                
            case .resetTimer:
                state.secondsElapsed = 0
                return .none
                
            case .timerTicked:
                state.secondsElapsed += 1
                return .none
                
            case .toggleTimer:
                state.isTimerActive.toggle()
                return .run { [isTimerActive = state.isTimerActive] send in
                  guard isTimerActive else { return }
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                      await send(.timerTicked, animation: .default)
                  }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                
            case .presentedSaveRoutineAlert:
                state.myRoutine = nil
                return .send(.resetTimer)
                
            case let .tappedToolbarCloseButton(secondsElapsed):
                state.destination = .alert(.saveWorkoutAlert(secondsElapsed))
                return .none
                
            case .tappedEdit:
                for index in state.workingOutSection.indices {
                    state.workingOutSection[index].toggleEditMode()
                }
                return .none
                
            case .destination(.presented(.alert(.tappedWorkoutAlertClose))):
                state.destination = .none
                state.myRoutine = nil
                return .send(.resetTimer)
                
            case .destination(.presented(.alert(.tappedWorkoutAlertCancel))):
                return .run { send in
                    await send(.toggleTimer)
                }
                
            case .destination(.presented(.alert(.tappedWorkoutAlertOk(let secondsElapsed)))):
                if let myRoutine = state.myRoutine {
                    let currentDate = Date()
                    let startDate = currentDate.addingTimeInterval(TimeInterval(-secondsElapsed))
                    insertWorkoutRoutine(
                        workout:  WorkoutRoutineState(
                            name: myRoutine.name,
                            startDate: startDate,
                            endDate: currentDate,
                            routineTime: secondsElapsed,
                            routines: myRoutine.routines
                        )
                    )
                }
                state.destination = .none
                
                return .send(.presentedSaveRoutineAlert(state.myRoutine))

            case .destination(.dismiss):
                return .none
                
            case let .workingOutSection(.element(sectionId, .tappedAddFooter)):
                if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                    let workoutSet = WorkoutSetState()
                    let index = state.workingOutSection[sectionIndex]
                        .workingOutRow.count
                    state.workingOutSection[sectionIndex]
                        .workingOutRow
                        .append(
                            WorkingOutRowReducer.State(
                                index: index + 1,
                                workoutSet: workoutSet,
                                editMode: .active
                            )
                        )
                    state.myRoutine?.routines[sectionIndex].sets.append(workoutSet)
                }
                return .none
                
            case let .workingOutSection(.element(sectionId, .workingOutRow(.element(rowId, action)))):
                switch action {
                case let .toggleCheck(isChecked):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex]
                        .workingOutRow.index(id: rowId) {
                        
                        state.myRoutine?.routines[sectionIndex]
                            .sets[rowIndex].isChecked = isChecked
                        state.myRoutine?.routines[sectionIndex]
                            .sets[rowIndex].endDate = isChecked ? Date() : nil
                        state.workingOutSection[sectionIndex]
                            .workingOutRow[rowIndex].isChecked = isChecked
                        
                        if let isAllTrue = state.myRoutine?.routines[sectionIndex].allTrue,
                           isAllTrue {
                            let setEndDates = state.myRoutine?.routines[sectionIndex]
                                .sets.compactMap { $0.endDate }
                            state.myRoutine?.routines[sectionIndex]
                                .averageEndDate = setEndDates?.calculateAverageSecondsBetweenDates()
                        }
                    }
                    return .none
                    
                case let .typeLab(lab):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex].workingOutRow.index(id: rowId),
                       let labValue = Int(lab) {
                        state.myRoutine?.routines[sectionIndex].sets[rowIndex].reps = labValue
                    }
                    return .none
                    
                case let .typeWeight(weight):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex].workingOutRow.index(id: rowId),
                       let weightValue = Double(weight) {
                        state.myRoutine?.routines[sectionIndex].sets[rowIndex].weight = weightValue
                    }
                    return .none
                case .setFocus, .dismissKeyboard:
                    return .none
                }
                
            case let .workingOutSection(.element(_, .setEditMode(editMode))):
                for index in state.workingOutSection.indices {
                    state.workingOutSection[index].editMode = editMode
                    let rows = state.workingOutSection[index].workingOutRow
                    for rowIndex in rows.indices {
                        state.workingOutSection[index].workingOutRow[rowIndex].editMode = editMode
                    }
                }
                return .none
            case .workingOutSection(.element(_, .workingOutHeader)):
                return .none
                    
            case let .workingOutSection(.element(sectionId, .deleteWorkoutSet(indexSet))):
                if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                    state.myRoutine?.routines[sectionIndex]
                        .sets.remove(atOffsets: indexSet)
                }
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
        .forEach(\.workingOutSection, action: \.workingOutSection) {
            WorkingOutSectionReducer()
        }
    }
    
    private func insertMyRoutine(myRoutine: MyRoutineState?) {
        do {
            if let myRoutineModel = myRoutine?.toModel() {
                myRoutineModel.routines.forEach {
                    $0.sets.forEach {
                        $0.isChecked = false
                    }
                }
                try myRoutineContext.add(myRoutineModel)
                try myRoutineContext.save()
            } else {
                throw MyRoutineDatabase.MyRoutineError.add
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func insertWorkoutRoutine(workout routine: WorkoutRoutineState) {
        do {
            try workoutRoutineContext.add(routine.toModel())
            try workoutRoutineContext.save()
        } catch {
            print(WorkoutRoutineDatabase.WorkoutRoutineError.add)
        }
    }
}

struct WorkingOutView: View {
    @Bindable var store: StoreOf<WorkingOutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutReducer>
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<WorkingOutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(store.scope(state: \.workingOutSection,
                                         action: \.workingOutSection)) { rowStore in
                    WorkingOutSection(store: rowStore)
                }
                Spacer().frame(height: 100)
            }
            .onAppear {
                viewStore.send(.toggleTimer)
            }
            .onDisappear {
                viewStore.send(.cancelTimer)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        viewStore.send(.tappedToolbarCloseButton(secondsElapsed: store.state.secondsElapsed))
                        viewStore.send(.toggleTimer)
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(viewStore.state.secondsElapsed.secondToHMS)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        viewStore.send(.tappedEdit)
                    }
                }
            }
            .navigationTitle(viewStore.myRoutine?.name ?? "")
            .listStyle(.grouped)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .alert($store.scope(state: \.destination?.alert,
                            action: \.destination.alert))
    }
}

extension AlertState where Action == WorkingOutReducer.Destination.Alert {
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
