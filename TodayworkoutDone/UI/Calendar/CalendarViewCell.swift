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
                .padding(8)
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
                    .size(CGSize(width: 5, height: 5))
                    .foregroundColor(Color.green)
                    .offset(x: CGFloat(23),
                            y: CGFloat(35))
            }
        }
    }
    
    func isFasting(on: Date) -> Bool {
        return false
    }
}

struct CalendarViewCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewCell(calendar: Calendar(identifier: .iso8601),
                         dayFormatter: DateFormatter(),
                         selectedDate: .constant(Date()),
                         date: Date())
    }
}
