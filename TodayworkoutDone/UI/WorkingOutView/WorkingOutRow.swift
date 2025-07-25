//
//  WorkingOutRow.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutRowReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var category: WorkoutCategoryState
        var workoutSet: WorkoutSetState
        var isChecked: Bool
        var editMode: EditMode
        var focusedField: Field?
        
        var repText: String = ""
        var originalRepText: String = ""
        
        var weightText: String = ""
        var originalWeightText: String = ""
        
        var restTimeText: String = ""
        var originalRestTimeText: String = ""
        
        var durationText: String = ""
        var originalDurationText: String = ""
        
        var timerView: CountdownTimerReducer.State
        @Presents var stopwatch: StopWatchFeature.State?
        
        init(category: WorkoutCategoryState,
             workoutSet: WorkoutSetState,
             editMode: EditMode = .inactive) {
            self.category = category
            self.id = workoutSet.id
            self.editMode = editMode
            self.workoutSet = workoutSet
            self.isChecked = workoutSet.isChecked
            
            repText = String(workoutSet.reps)
            weightText = String(workoutSet.weight)
            restTimeText = workoutSet.restTime.formattedTime()
            timerView = CountdownTimerReducer.State(totalTime: workoutSet.restTime)
        }
    }
    
    enum Action {
        case toggleCheck(isChecked: Bool)
        case typeRep(rep: String)
        case typeWeight(weight: String)
        case typeRestTime(restTime: String)
        case typeDuration(duration: String)
        case setFocus(Field?)
        case dismissKeyboard
        case timerView(CountdownTimerReducer.Action)
        
        case presentStopWatch
        case stopwatch(PresentationAction<StopWatchFeature.Action>)
    }
    
    enum Field: Hashable {
        case repText
        case weightText
        case restTimeText
        case durationText
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.timerView, action: \.timerView) {
            CountdownTimerReducer()
        }
        Reduce { state, action in
            switch action {
            case let .toggleCheck(isChecked):
                if !isChecked {
                    state.timerView.timeRemaining = state.workoutSet.restTime
                }
                return .none
            case let .typeRep(rep):
                if let formattedRep = Int(rep) {
                    state.workoutSet.reps = formattedRep
                    state.repText = rep
                }
                return .none
            case let .typeWeight(weight):
                if let formattedWeight = Double(weight) {
                    state.workoutSet.weight = formattedWeight
                    state.weightText = weight
                }
                return .none
            case let .typeRestTime(restTime):
                if !restTime.isEmpty {
                    state.restTimeText = restTime.formattedTime()
                }
                
                return .none
            case let .typeDuration(duration):
                if !duration.isEmpty {
                    state.durationText = duration.formattedTime()
                }
                return .none
            case let .setFocus(field):
                state.focusedField = field
                switch field {
                case .repText:
                    state.originalRepText = state.repText
                    state.repText = ""
                case .weightText:
                    state.originalWeightText = state.weightText
                    state.weightText = ""
                case .restTimeText:
                    state.originalRestTimeText = state.restTimeText
                    state.restTimeText = ""
                case .durationText:
                    state.originalDurationText = state.durationText
                    state.durationText = ""
                case .none:
                    break
                }
                return .none
            case .dismissKeyboard:
                state.focusedField = nil
                return .none
            case .timerView:
                return .none
                
            case .presentStopWatch:
                state.stopwatch = StopWatchFeature.State()
                return .none
            case .stopwatch(.presented(.close)):
                if let stopwatch = state.stopwatch {
                    state.workoutSet.duration = Int(stopwatch.elapsedTime)
                }
                return .none
            case .stopwatch:
                return .none
            }
        }
        .ifLet(\.$stopwatch, action: \.stopwatch) {
            StopWatchFeature()
        }
    }
}

struct WorkingOutRow: View {
    @Bindable var store: StoreOf<WorkingOutRowReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutRowReducer>
    @FocusState private var focusedField: WorkingOutRowReducer.Field?
    @State private var progressOffset: CGFloat = 100
    
    init(store: StoreOf<WorkingOutRowReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            switch viewStore.category.categoryType {
            case .strength:
                orderView()
                prevAndTimerView()
                repsAndWeightView()
                restTimeView()
            case .pilates, .yoga, .cardio:
                orderView()
                prevAndTimerView()
                durationView()
                restTimeView()
            case .stretching:
                stopWatchView()
            }
        }
        .frame(minHeight: 25)
        .padding(.vertical, 5)
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == .restTimeText,
                viewStore.restTimeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewStore.send(.typeRestTime(restTime: store.originalRestTimeText))
            }
            if oldValue == .weightText,
                viewStore.weightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewStore.send(.typeWeight(weight: store.originalWeightText))
            }
            if oldValue == .repText,
                viewStore.repText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewStore.send(.typeRep(rep: store.originalRepText))
            }
            if newValue != nil {
                viewStore.send(.setFocus(newValue))
            }
        }
        .onChange(of: viewStore.focusedField) { _, newValue in
            focusedField = newValue
        }
        .fullScreenCover(
            item: $store.scope(state: \.stopwatch,
                               action: \.stopwatch)
        ) { store in
            StopWatchView(store: store)
        }
    }
    
    @ViewBuilder
    private func orderView() -> some View {
        if viewStore.editMode == .active {
            Menu {
                Button(action: {

                }) {
                    Label("워밍업", systemImage: "pencil")
                }
                Button(action: {

                }) {
                    Label("드롭", systemImage: "pencil")
                }
                Button(action: {

                }) {
                    Label("실패", systemImage: "pencil")
                }
            } label: {
                Text("\(viewStore.workoutSet.order)")
                    .padding([.leading, .trailing], 5)
                    .padding([.top, .bottom], 3)
                    .font(.system(size: 17))
                    .frame(minWidth: 30)
                    .foregroundStyle(.white)
                    .background(Color.personal.opacity(0.6))
                    .cornerRadius(3.0)
            }
        } else {
            Toggle(
                "",
                isOn: viewStore.binding(
                    get: { $0.isChecked },
                    send: { WorkingOutRowReducer.Action.toggleCheck(isChecked: $0) }
                )
            )
            .toggleStyle(CheckboxToggleStyle(style: .square))
            .padding(.leading, 7)
            .foregroundStyle(Color.personal)
        }
    }
    
    @ViewBuilder
    private func prevAndTimerView() -> some View {
        if viewStore.editMode == .inactive {
            if viewStore.isChecked {
                CountdownTimerView(store: store.scope(state: \.timerView,
                                                      action: \.timerView))
                .frame(maxWidth: .infinity, minHeight: 25)
                .background(.clear)
                .transition(.opacity.animation(.easeIn))
            } else {
                Text("\(viewStore.workoutSet.prevReps) x \(String(format: "%.1f", viewStore.workoutSet.prevWeight))")
                    .font(.system(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func repsAndWeightView() -> some View {
        if viewStore.editMode == .active {
            TextField("count", text: viewStore.binding(
                get: { $0.repText },
                send: { WorkingOutRowReducer.Action.typeRep(rep: $0) })
            )
            .font(.system(size: 17))
            .frame(minWidth: 100)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .repText)
        } else {
            Text(String(viewStore.workoutSet.reps))
                .font(.system(size: 17))
                .frame(minWidth: 85)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
        
        if viewStore.editMode == .active {
            TextField("weight", text: viewStore.binding(
                get: { $0.weightText },
                send: { WorkingOutRowReducer.Action.typeWeight(weight: $0) })
            )
            .font(.system(size: 17))
            .frame(minWidth: 100)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .weightText)
        } else {
            Text(String(viewStore.workoutSet.weight))
                .font(.system(size: 17))
                .frame(minWidth: 85)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    private func durationView() -> some View {
        if viewStore.editMode == .active {
            TextField("진행 시간",
                      text: viewStore.binding(get: \.durationText,
                                              send: { .typeDuration(duration: $0) }))
            .font(.system(size: 17))
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .focused($focusedField, equals: .durationText)
        } else {
            Text(String(viewStore.workoutSet.duration))
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    private func restTimeView() -> some View {
        if viewStore.editMode == .active {
            TextField("시간 입력",
                      text: viewStore.binding(get: \.restTimeText,
                                              send: { .typeRestTime(restTime: $0) }))
            .font(.system(size: 17))
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .restTimeText)
        }
    }
    
    @ViewBuilder
    private func stopWatchView() -> some View {
        if viewStore.editMode == .inactive {
            Text("\(viewStore.workoutSet.prevDuration)")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
        }
        Text(String(viewStore.workoutSet.duration.formattedTime()))
            .font(.system(size: 17))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .background(Color(uiColor: .secondarySystemFill))
            .cornerRadius(5)
        Button(action: {
            viewStore.send(.presentStopWatch)
        }) {
            Text("스탑와치 시작")
                .frame(minHeight: 30)
                .frame(maxWidth: .infinity)
                .background(Color.personal)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.vertical, 5)
        }
        .disabled(viewStore.editMode == .active)
    }
}
