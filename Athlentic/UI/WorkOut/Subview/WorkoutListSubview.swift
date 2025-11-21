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
        @Presents var workoutInfo: WorkoutInfoFeature.State?
        let id: UUID
        var workout: WorkoutState
    }
    
    enum Action {
        case didTapped
        case tappedInfo
        case workoutInfo(PresentationAction<WorkoutInfoFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTapped:
                state.workout.isSelected = !state.workout.isSelected
                return .none
            case .tappedInfo:
                state.workoutInfo = WorkoutInfoFeature.State(workout: state.workout)
                return .none
            case .workoutInfo:
                return .none
            }
        }
        .ifLet(\.$workoutInfo, action: \.workoutInfo) {
            WorkoutInfoFeature()
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
//                    if let image = UIImage(named: "default") {
//                        Image(uiImage: image)
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .cornerRadius(10)
//                    }
                    Text(viewStore.workout.name)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Color.todBlack)
                    Spacer()
                    if viewStore.workout.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.personal)
                    } else {
                        Button(action: {
                            viewStore.send(.tappedInfo)
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color.grayC3)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
        .padding()
        .background(Color.contentBackground)
        .cornerRadius(10)
        .fullScreenCover(
            item:  $store.scope(state: \.workoutInfo,
                                action: \.workoutInfo)
        ) { store in
            WorkoutInfoView(store: store)
        }
    }
}
