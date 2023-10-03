//
//  CalendarViewCell.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/08.
//

import SwiftUI

struct CalendarViewCell: View {
    var calendar: Calendar = .current
    var dayFormatter: DateFormatter
    @Binding var selectedDate: Date
    var date: Date
    var workoutRoutines: [WorkoutRoutine]
    
    var body: some View {
        VStack {
            Text(dayFormatter.string(from: date))
                .padding(2)
                .foregroundColor(calendar.isDateInToday(date) ? Color.white : .primary)
                .frame(minWidth: 25, maxHeight: .infinity)
                .background(
                    calendar.isDateInToday(date) ? Color.green
                    : calendar.isDate(date, inSameDayAs: selectedDate) ? .yellow
                    : .clear
                )
                .contentShape(Rectangle())
                .cornerRadius(7)
            
            if workoutRoutines.contains(where: {
                $0.date.year == date.year
                && $0.date.month == date.month
                && $0.date.day == date.day
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

struct CalendarViewCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewCell(calendar: Calendar(identifier: .iso8601),
                         dayFormatter: DateFormatter(dateFormat: "d", calendar: .current),
                         selectedDate: .constant(Date()),
                         date: Date(),
                         workoutRoutines: [])
    }
}
