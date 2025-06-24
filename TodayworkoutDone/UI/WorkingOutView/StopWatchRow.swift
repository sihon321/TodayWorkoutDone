//
//  Untitled.swift
//  TodayworkoutDone
//
//  Created by oceano on 6/20/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct StopWatchRowFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        let id: UUID
        var workoutSet: WorkoutSetState
        var editMode: EditMode
        var isChecked: Bool
        
        init(workoutSet: WorkoutSetState, editMode: EditMode = .inactive) {
            self.id = workoutSet.id
            self.editMode = editMode
            self.workoutSet = workoutSet
            self.isChecked = workoutSet.isChecked
        }
    }
    
    enum Action {
        case stopwatch
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case stopwatch(StopWatchFeature)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .stopwatch:
                    state.destination = .stopwatch(StopWatchFeature.State())
                    return .none
                case .destination(.presented(.stopwatch(.close))):
                    return .none
                case .destination:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

struct StopWatchRow: View {
    @Bindable var store: StoreOf<StopWatchRowFeature>
    @ObservedObject var viewStore: ViewStoreOf<StopWatchRowFeature>
    
    init(store: StoreOf<StopWatchRowFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            if viewStore.editMode == .inactive {
                Text("이전 시간")
                    .font(.system(size: 17))
                    .frame(minWidth: 140)
                    .foregroundStyle(.secondary)
            }
            Text(String(viewStore.workoutSet.reps))
                .font(.system(size: 17))
                .frame(minWidth: 85)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
            Button(action: {
                viewStore.send(.stopwatch)
            }) {
                Text("스탑와치 시작")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.personal)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 5)
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.stopwatch,
                               action: \.destination.stopwatch)
        ) { store in
            StopWatchView(store: store)
        }
    }
}

#Preview {
    StopWatchRow(store: Store(
        initialState: StopWatchRowFeature.State(
            workoutSet: WorkoutSetState(model: WorkoutSet.mockedData[0])
        )
    ) {
        StopWatchRowFeature()
    })
}
