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
        var index: Int
        var workoutSet: WorkoutSetState
        var isChecked: Bool
        var editMode: EditMode
        var focusedField: Field?
        
        var repText: String = ""
        var weightText: String = ""
        
        init(index: Int, workoutSet: WorkoutSetState, editMode: EditMode = .inactive) {
            self.index = index
            self.id = workoutSet.id
            self.editMode = editMode
            self.workoutSet = workoutSet
            self.isChecked = workoutSet.isChecked
            
            repText = String(workoutSet.reps)
            weightText = String(workoutSet.weight)
        }
    }
    
    enum Action {
        case toggleCheck(isChecked: Bool)
        case typeLab(lab: String)
        case typeWeight(weight: String)
        case setFocus(Field?)
        case dismissKeyboard
    }
    
    enum Field: Hashable {
        case repText
        case weightText
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleCheck:
                return .none
            case let .typeLab(rep):
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
            case let .setFocus(field):
                state.focusedField = field
                return .none
            case .dismissKeyboard:
                state.focusedField = nil
                return .none
            }
        }
    }
}

struct WorkingOutRow: View {
    @Bindable var store: StoreOf<WorkingOutRowReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutRowReducer>
    @FocusState private var focusedField: WorkingOutRowReducer.Field?
    
    init(store: StoreOf<WorkingOutRowReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            if viewStore.editMode == .active {
                Button(action: {}, label: {
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
                        Text("\(viewStore.index)")
                            .padding([.leading, .trailing], 5)
                            .padding([.top, .bottom], 3)
                            .font(.system(size: 17))
                            .frame(minWidth: 30)
                            .foregroundStyle(.white)
                            .background(Color.personal.opacity(0.6))
                            .cornerRadius(3.0)
                    }
                })
            } else {
                Toggle(
                    "",
                    isOn: viewStore.binding(
                        get: { $0.isChecked },
                        send: { WorkingOutRowReducer.Action.toggleCheck(isChecked: $0) }
                    )
                )
                .toggleStyle(CheckboxToggleStyle(style: .square))
                .padding(.leading, -7)
            }
            
            if viewStore.editMode == .inactive {
                Text("\(viewStore.workoutSet.prevReps) x \(String(format: "%.1f", viewStore.workoutSet.prevWeight))")
                    .font(.system(size: 17))
                    .frame(minWidth: 140)
                    .foregroundStyle(.secondary)
            }
            
            if viewStore.editMode == .active {
                TextField("count", text: viewStore.binding(
                    get: { $0.repText },
                    send: { WorkingOutRowReducer.Action.typeLab(lab: $0) })
                )
                .font(.system(size: 17))
                .frame(minWidth: 140)
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
                .frame(minWidth: 140)
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
        .frame(height: 25)
        .padding(.vertical, 5)
        .onChange(of: focusedField) { _, newValue in
            viewStore.send(.setFocus(newValue))
        }
        .onChange(of: viewStore.focusedField) { _, newValue in
            focusedField = newValue
        }
    }
}
