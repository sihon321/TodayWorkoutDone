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
                return .none
            }
        }
    }
}

struct WorkoutListSubview: View {
    @Bindable var store: StoreOf<WorkoutListSubviewReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListSubviewReducer>
    
    init(store: StoreOf<WorkoutListSubviewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            Button(action: {
                viewStore.send(.didTapped)
            }) {
                HStack {
                    if let image = UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                    Text(viewStore.workout.name)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.black)
                    Spacer()
                    if viewStore.workout.isSelected {
                        Image(systemName:"checkmark")
                            .foregroundStyle(Color.personal)
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
