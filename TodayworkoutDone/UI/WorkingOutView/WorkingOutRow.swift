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
        var workoutSet: WorkoutSet
        var editMode: EditMode
        
        init(workoutSet: WorkoutSet = .init(), editMode: EditMode = .inactive) {
            self.id = workoutSet.id
            self.editMode = editMode
            self.workoutSet = workoutSet
        }
    }
    
    enum Action {
        case toggleCheck(isChecked: Bool)
        case typeLab(lab: String)
        case typeWeight(weight: String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleCheck:
                return .none
            case .typeLab:
                return .none
            case .typeWeight:
                return .none
            }
        }
    }
}

struct WorkingOutRow: View {
    @Bindable var store: StoreOf<WorkingOutRowReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutRowReducer>
    
    init(store: StoreOf<WorkingOutRowReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            Toggle(
                "",
                isOn: viewStore.binding(
                    get: { $0.workoutSet.isChecked },
                    send: { WorkingOutRowReducer.Action.toggleCheck(isChecked: $0) }
                )
            )
            .toggleStyle(CheckboxToggleStyle(style: .square))
            Spacer()
            if viewStore.editMode == .active {
                TextField("count", text: viewStore.binding(
                    get: { String($0.workoutSet.lab) },
                    send: { WorkingOutRowReducer.Action.typeLab(lab: $0) })
                )
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(5)
            } else {
                Text(String(viewStore.workoutSet.lab))
            }
            Spacer()
            Text("\(viewStore.workoutSet.prevLab)")
                .frame(minWidth: 40)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
            Spacer()
            if viewStore.editMode == .active {
                TextField("weight", text: viewStore.binding(
                    get: { String($0.workoutSet.weight) },
                    send: { WorkingOutRowReducer.Action.typeWeight(weight: $0) })
                )
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(5)
            } else {
                Text(String(viewStore.workoutSet.weight))
            }
            Spacer()
            Text(String(format: "%.1f", viewStore.workoutSet.prevWeight))
                .frame(minWidth: 40)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }
}
