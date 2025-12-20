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
        var categoryType: WorkoutCategoryState.WorkoutCategoryType
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
        
        init(categoryType: WorkoutCategoryState.WorkoutCategoryType,
             workoutSet: WorkoutSetState,
             editMode: EditMode = .inactive) {
            self.categoryType = categoryType
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
            case .stopwatch(.presented(.complete)):
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
    @FocusState private var focusedField: WorkingOutRowReducer.Field?
    @State private var progressOffset: CGFloat = 100
    
    init(store: StoreOf<WorkingOutRowReducer>) {
        self.store = store
    }
    
    var body: some View {
        HStack {
            switch store.categoryType {
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
               store.restTimeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                store.send(.typeRestTime(restTime: store.originalRestTimeText))
            }
            if oldValue == .weightText,
               store.weightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                store.send(.typeWeight(weight: store.originalWeightText))
            }
            if oldValue == .repText,
               store.repText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                store.send(.typeRep(rep: store.originalRepText))
            }
            if newValue != nil {
                store.send(.setFocus(newValue))
            }
        }
        .onChange(of: store.focusedField) { _, newValue in
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
        if store.editMode == .active {
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
                Text("\(store.workoutSet.order)")
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
                isOn: Binding(
                    get: { store.isChecked },
                    set: { value in
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            _ = store.send(.toggleCheck(isChecked: value))
                        }
                    }
                )
            )
            .toggleStyle(CheckboxToggleStyle(style: .square))
            .padding(.leading, 7)
            .foregroundStyle(Color.personal)
            .sensoryFeedback(.selection, trigger: store.isChecked)
        }
    }
    
    @ViewBuilder
    private func prevAndTimerView() -> some View {
        if store.editMode == .inactive {
            if store.isChecked && store.timerView.timeRemaining != 0 {
                CountdownTimerView(store: store.scope(state: \.timerView,
                                                      action: \.timerView))
                .frame(maxWidth: .infinity, minHeight: 25)
                .background(.clear)
                .transition(.opacity.animation(.easeIn))
            } else {
                Text("\(store.workoutSet.prevReps) x \(String(format: "%.1f", store.workoutSet.prevWeight))")
                    .font(.system(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func repsAndWeightView() -> some View {
        if store.editMode == .active {
            TextField("count", text: Binding(
                get: { store.repText },
                set: { store.send(.typeRep(rep: $0)) }
            ))
            .font(.system(size: 17))
            .frame(minWidth: 100)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .repText)
        } else {
            Text(String(store.workoutSet.reps))
                .font(.system(size: 17))
                .frame(minWidth: 85)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }

        if store.editMode == .active {
            TextField("weight", text: Binding(
                get: { store.weightText },
                set: { store.send(.typeWeight(weight: $0) ) }
            )       )
            .font(.system(size: 17))
            .frame(minWidth: 100)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .weightText)
        } else {
            Text(String(store.workoutSet.weight))
                .font(.system(size: 17))
                .frame(minWidth: 85)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    private func durationView() -> some View {
        if store.editMode == .active {
            TextField("진행 시간",
                      text: Binding(
                        get: { store.durationText },
                        set: { store.send(.typeDuration(duration: $0)) }
                    ))
            .font(.system(size: 17))
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .focused($focusedField, equals: .durationText)
        } else {
            Text(String(store.workoutSet.duration.formattedTime()))
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }

    @ViewBuilder
    private func restTimeView() -> some View {
        if store.editMode == .active {
            TextField("시간 입력",
                      text: Binding(
                        get: { store.restTimeText },
                        set: { store.send(.typeRestTime(restTime: $0)) }
                    ))
            .font(.system(size: 17))
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .restTimeText)
        }
    }
    
    @ViewBuilder
    private func stopWatchView() -> some View {
        if store.editMode == .inactive {
            Text("\(store.workoutSet.prevDuration)")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
        }
        Text(String(store.workoutSet.duration.formattedTime()))
            .font(.system(size: 17))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .background(Color(uiColor: .secondarySystemFill))
            .cornerRadius(5)
        Button(action: {
            store.send(.presentStopWatch)
        }) {
            Text("스탑와치 시작")
                .frame(minHeight: 30)
                .frame(maxWidth: .infinity)
                .background(Color.personal)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.vertical, 5)
        }
        .disabled(store.editMode == .active)
    }
}
