//
//  WorkingOutRowView.swift
//  TodayworkoutDone
//
//  Created by ocean on 11/21/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutRowViewReducer {
    @ObservableState
    struct State: Equatable {
        var workoutSet: WorkoutSet
        var editMode: EditMode
    }
    
    enum Action {
        case toggleCheck(isChecked: Bool)
        case typeLab(lab: String)
        case typeWeight(weight: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .toggleCheck(isChecked):
                return .none
            case let .typeLab(lab):
                return .none
            case .typeWeight:
                return .none
            }
        }
    }
}

struct WorkingOutRowView: View {
    @Bindable var store: StoreOf<WorkingOutRowViewReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutRowViewReducer>
    
    init(store: StoreOf<WorkingOutRowViewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            Toggle(
                "",
                isOn: viewStore.binding(
                    get: { $0.workoutSet.isChecked },
                    send: { WorkingOutRowViewReducer.Action.toggleCheck(isChecked: $0) }
                )
            )
            .toggleStyle(CheckboxToggleStyle(style: .square))
            Spacer()
            if viewStore.editMode == .active {
                TextField("count", text: viewStore.binding(
                    get: { String($0.workoutSet.lab) },
                    send: { WorkingOutRowViewReducer.Action.typeLab(lab: $0) })
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
                    send: { WorkingOutRowViewReducer.Action.typeWeight(weight: $0) })
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
