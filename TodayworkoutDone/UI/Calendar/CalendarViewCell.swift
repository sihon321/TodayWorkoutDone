//
//  CalendarViewCell.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/08.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CalendarCellReducer {
    @ObservableState
    struct State: Equatable {
        var calendar: Calendar = .current
        var dayFormatter: DateFormatter
        var selectedDate: Date
        var date: Date
        var workoutRoutines: [WorkoutRoutine] = []
    }
}

struct CalendarViewCell: View {
    @Bindable var store: StoreOf<CalendarCellReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarCellReducer>
    
    init(store: StoreOf<CalendarCellReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            Text(store.dayFormatter.string(from: store.date))
                .padding(2)
                .foregroundColor(store.calendar.isDateInToday(store.date) ? Color.white : .primary)
                .frame(minWidth: 25, maxHeight: .infinity)
                .background(
                    store.calendar.isDateInToday(store.date) ? Color.green
                    : store.calendar.isDate(store.date, inSameDayAs: store.selectedDate) ? .yellow
                    : .clear
                )
                .contentShape(Rectangle())
                .cornerRadius(7)
            
            if store.workoutRoutines.contains(where: {
                $0.date.year == store.date.year
                && $0.date.month == store.date.month
                && $0.date.day == store.date.day
            }) {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

