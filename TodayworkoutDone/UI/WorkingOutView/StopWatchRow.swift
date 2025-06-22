//
//  Untitled.swift
//  TodayworkoutDone
//
//  Created by oceano on 6/20/25.
//

import SwiftUI
import ComposableArchitecture

struct StopWatchRow: View {
    @Bindable var store: StoreOf<WorkingOutSectionReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutSectionReducer>
    
    init(store: StoreOf<WorkingOutSectionReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewStore.routine.workout.name)
                .font(.system(size: 20, weight: .semibold))
                .padding()
            HStack {
                Button(action: {
                    viewStore.send(.stopwatch)
                }) {
                    Text("스탑와치 시작")
                        .frame(maxWidth: .infinity)
                }
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
    StopWatchRow(store: Store(initialState: WorkingOutSectionReducer.State(routine: RoutineState(model: Routine.mockedData[0]), editMode: .inactive)) {
        WorkingOutSectionReducer()
    })
}
