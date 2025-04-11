//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkoutListSubviewReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var myRoutine: MyRoutineState
        var workout: WorkoutState
    }
    
    enum Action {
        case didTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTapped:
                state.workout.isSelected = !state.workout.isSelected
                if state.workout.isSelected {
                    state.myRoutine.routines.append(RoutineState(workout: state.workout))
                } else {
//                    state.myRoutine.routines.removeAll { $0.workout.name == state.workout.name }
                }
                return .none
            }
        }
    }
}

struct WorkoutListSubview: View {
    @Bindable var store: StoreOf<WorkoutListSubviewReducer>

    var body: some View {
        VStack {
            Button(action: {
                store.send(.didTapped)
            }) {
                HStack {
                    if let image = UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .padding([.leading], 15)
                    }
                    Text(store.workout.name)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.black)
                    Spacer()
                    if store.myRoutine.routines.contains(where: { $0.workout.id == store.workout.id }) {
                        Image(systemName:"checkmark")
                            .foregroundStyle(.black)
                            .padding(.trailing, 15)
                    }
                }
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
    }
}
