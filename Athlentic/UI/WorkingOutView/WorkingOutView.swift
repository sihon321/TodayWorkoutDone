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
        @Shared(.appStorage("weight")) var weight: Double?
        @Presents var destination: Destination.State?
        var myRoutine: MyRoutineState?
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State> = []
        
        var isTimerActive = false
        var isEdit = false
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case tappedToolbarCloseButton(secondsElapsed: Int)
        case tappedEdit
        case tappedAdd
        
        case cancelTimer
        case resetTimer
        case timerTicked
        case toggleTimer
        case addTimer(Int)
        
        case presentedSaveRoutineAlert(MyRoutineState?)
        
        indirect case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
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
                state.myRoutine?.secondsElapsed = 0
                return .none
                
            case .timerTicked:
                state.myRoutine?.secondsElapsed += 1
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
                
            case .addTimer(let seconds):
                state.myRoutine?.secondsElapsed += seconds
                return .none
                
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
                state.isEdit.toggle()
                return .none
                
            case .tappedAdd:
                state.destination = .addWorkoutCategory(
                    AddWorkoutCategoryReducer.State(
                        routines: state.myRoutine!.routines
                    )
                )
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
                    var routines = myRoutine.routines
                    let currentDate = Date()
                    let startDate = currentDate.addingTimeInterval(TimeInterval(-secondsElapsed))
                    
                    for (routineIndex, routine) in routines.enumerated() {
                       routines[routineIndex].sets = routine.sets.filter { $0.isChecked }
                        var dates = myRoutine.routines[routineIndex].sets
                            .filter({ $0.endDate != nil })
                            .map({
                                return $0.endDate! - Double($0.restTime)
                            })
                        if routineIndex == 0 {
                            dates.insert(startDate, at: 0)
                        } else if let prevSetEndDate = myRoutine.routines[routineIndex - 1].sets
                            .filter({ $0.endDate != nil })
                            .last?.endDate {
                            dates.insert(prevSetEndDate, at: 0)
                        }
                        if let avgSetDuration = self.calculateTimeDifferences(dates: dates) {
                            let mets: Double = 5.0
                            let restMets : Double = 1.5
                            state.myRoutine?.routines[routineIndex].avgSetDuration = avgSetDuration
                            if let weight = state.weight {
                                let totalActivityTime = avgSetDuration * Double(routine.sets.count)
                                let activityCalories = (mets * 3.5 * weight / 200) * (totalActivityTime / 60)
                                let restDuration = routine.sets.reduce(0) { $0 + $1.restTime }
                                let restCalories = (restMets * 3.5 * weight / 200) * (Double(restDuration) / 60)
                                state.myRoutine?.routines[routineIndex].calories = activityCalories + restCalories
                            }
                        }
                    }
                    
                    insertWorkoutRoutine(
                        workout: WorkoutRoutineState(
                            name: myRoutine.name,
                            startDate: startDate,
                            endDate: currentDate,
                            routineTime: myRoutine.secondsElapsed,
                            routines: routines
                        )
                    )
                }
                state.destination = .none
                
                return .send(.presentedSaveRoutineAlert(state.myRoutine))

            case .destination:
                return .none
                
            case let .workingOutSection(.element(sectionId, .tappedAddFooter)):
                if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                    let index = state.workingOutSection[sectionIndex]
                        .workingOutRow.count
                    let workoutSet = WorkoutSetState(order: index + 1)
                    let categoryName = state.workingOutSection[sectionIndex].routine.workout.categoryName
                    let categoryType = WorkoutCategoryState.WorkoutCategoryType(rawValue: categoryName) ?? .strength
                    state.workingOutSection[sectionIndex]
                        .workingOutRow
                        .append(
                            WorkingOutRowReducer.State(
                                categoryType: categoryType,
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
                        state.myRoutine?.routines[sectionIndex].endDate = Date()
                    }
                    return .none
                    
                case let .typeRep(rep):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex].workingOutRow.index(id: rowId),
                       let labValue = Int(rep) {
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
                case .typeRestTime(restTime: let restTime):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex]
                        .workingOutRow
                        .index(id: rowId) {
                        state.myRoutine?
                            .routines[sectionIndex]
                            .sets[rowIndex]
                            .restTime = restTime.timeStringToSeconds()
                    }
                    return .none
                case .typeDuration(let duration):
                    if let sectionIndex = state.workingOutSection.index(id: sectionId),
                       let rowIndex = state.workingOutSection[sectionIndex]
                        .workingOutRow
                        .index(id: rowId) {
                        state.myRoutine?
                            .routines[sectionIndex]
                            .sets[rowIndex]
                            .duration = duration.timeStringToSeconds()
                    }
                    return .none
                case .setFocus, .dismissKeyboard, .timerView, .presentStopWatch:
                    return .none
                case .stopwatch:
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
    
    private func insertWorkoutRoutine(workout routine: WorkoutRoutineState) {
        do {
            try workoutRoutineContext.add(routine.toModel())
            try workoutRoutineContext.save()
        } catch {
            print(WorkoutRoutineDatabase.WorkoutRoutineError.add)
        }
    }
    
    private func calculateTimeDifferences(
        dates: [Date]
    ) -> Double? {
        let sortedDates = dates.reversed()
        let intervals = zip(sortedDates, sortedDates.dropFirst()).map { later, earlier in
            let intervalInSeconds = later.timeIntervalSince(earlier)
            return intervalInSeconds
        }
        
        guard !intervals.isEmpty else {
            return nil
        }
        
        let sum = intervals.reduce(0, +)
        return sum / Double(intervals.count)
    }
}

struct WorkingOutView: View {
    @Bindable var store: StoreOf<WorkingOutReducer>
    @State private var offsetY: CGFloat = .zero
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<WorkingOutReducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button("Close") {
                    store.send(.tappedToolbarCloseButton(secondsElapsed: store.state.myRoutine?.secondsElapsed ?? 0))
                    store.send(.toggleTimer)
                }
                .font(.system(size: 17))
                .frame(width: 60, height: 20)
                Spacer()
                WithViewStore(self.store, observe: { $0.myRoutine?.secondsElapsed.secondToHMS }) { store in
                    Text(store.state ?? "")
                        .font(.system(size: 17))
                        .monospacedDigit()
                        .frame(maxHeight: .infinity)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .id("Timer")
                }
                Spacer()
                toggleButton()
            }
            .geometryGroup()
            .frame(height: 70)
            .padding(.horizontal, 15)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text(store.myRoutine?.name ?? "")
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 15)
                    ForEach(
                        store.scope(state: \.workingOutSection,
                                    action: \.workingOutSection)
                    ) { rowStore in
                        WorkingOutSection(store: rowStore)
                            .padding(.bottom, 15)
                    }
                    .padding(.bottom, 30)
                    
                    if store.isEdit {
                        Button("워크아웃 추가") {
                            store.send(.tappedAdd)
                        }
                        .buttonStyle(AddWorkoutButtonStyle())
                        .fullScreenCover(
                            item: $store.scope(state: \.destination?.addWorkoutCategory,
                                               action: \.destination.addWorkoutCategory)
                        ) { store in
                            AddWorkoutCategoryView(store: store)
                        }
                    }
                    Spacer().frame(height: 100)
                }
            }
        }
        .onAppear {
            store.send(.toggleTimer)
        }
        .onDisappear {
            store.send(.cancelTimer)
            for sectionStore in store.workingOutSection {
                for row in sectionStore.workingOutRow {
                    store.send(.workingOutSection(.element(id: sectionStore.id, action: .workingOutRow(.element(id: row.id, action: .timerView(.stop))))))
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .alert($store.scope(state: \.destination?.alert,
                            action: \.destination.alert))
        .tint(.todBlack)
    }
    
    func toggleButton() -> some View {
        ZStack {
            Capsule()
                .frame(width: 60, height: 30)
                .foregroundStyle(Color(!store.isEdit ? .personal : .gray88))
            ZStack{
                Circle()
                    .frame(width: 35, height: 25)
                    .foregroundStyle(Color.slideCardBackground)
                if store.isEdit {
                    Image(systemName: "lock.open.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                } else {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 10, height: 15)
                }

            }
            .shadow(color: .personal.opacity(0.14), radius: 4, x: 0, y: 2)
            .offset(x: !store.isEdit ? 15 : -15)
            .padding(15)
            .animation(.spring(), value: !store.isEdit)
        }
        .onTapGesture {
            store.send(.tappedEdit)
        }
    }
    
    private var hiddenView: some View {
        GeometryReader { proxy in
            let offsetY = proxy.frame(in: .global).minY
            Color.clear
                .preference(key: ScrollOffsetPreferenceKey.self, value: offsetY)
                .frame(height: 0)
        }
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
