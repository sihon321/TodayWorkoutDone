//
//  CalendarDetailView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/17.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CalendarDetailReducer {
    @ObservableState
    struct State: Equatable {
        var date: Date
        var workoutRoutines: [WorkoutRoutine]
    }
    
    enum Action: Equatable {
        
    }
}

struct CalendarDetailView: View {
    @Bindable var store: StoreOf<CalendarDetailReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarDetailReducer>
    
    init(store: StoreOf<CalendarDetailReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ScrollView {
            ForEach(viewStore.workoutRoutines) { workoutRoutine in
                CalendarDetailSubView(workoutRoutine: workoutRoutine)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
        }
        .padding([.top], 30)
        .padding([.leading, .bottom, .trailing], 15)
    }
}
