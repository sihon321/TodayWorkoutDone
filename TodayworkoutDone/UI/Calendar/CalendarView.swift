//
//  CalendarView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/28.
//

import SwiftUI
import Combine

struct CalendarView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var isPresented = false
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date()

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        NavigationView {
            CalendarViewComponent(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button(action: {
                        isPresented = true
                    }) {
                        CalendarViewCell(calendar: calendar,
                                         dayFormatter: dayFormatter,
                                         selectedDate: $selectedDate,
                                         date: date)
                    }
                    .sheet(isPresented: $isPresented) {
                        CalendarDetailView(isPresented: $isPresented)
                    }
                },
                trailing: { date in
                    Rectangle()
                        .foregroundColor(.clear)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date)).fontWeight(.bold)
                },
                title: { date in
                    Text(monthFormatter.string(from: date))
                        .font(.title)
                        .padding(.vertical, 8)
                }
            )
            .equatable()
        }
        .padding()
        .background(Color(0xf4f4f4))
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

// MARK: - Previews

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(calendar: .current)
        //            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
