//
//  CalendarViewCell.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/08.
//

import SwiftUI

struct CalendarViewCell: View {
    var calendar: Calendar
    var dayFormatter: DateFormatter
    @Binding var selectedDate: Date
    var date: Date
    
    var body: some View {
        VStack {
            Text(dayFormatter.string(from: date))
                .padding(2)
                .foregroundColor(calendar.isDateInToday(date) ? Color.white : .primary)
                .background(
                    calendar.isDateInToday(date) ? Color.green
                    : calendar.isDate(date, inSameDayAs: selectedDate) ? .yellow
                    : .clear
                )
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .cornerRadius(7)
            
            if (isFasting(on: date)) {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    func isFasting(on: Date) -> Bool {
        return true
    }
}

struct CalendarViewCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewCell(calendar: Calendar(identifier: .iso8601),
                         dayFormatter: DateFormatter(dateFormat: "d", calendar: .current),
                         selectedDate: .constant(Date()),
                         date: Date())
    }
}
