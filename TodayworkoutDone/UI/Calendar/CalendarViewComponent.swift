//
//  CalendarViewComponent.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/16.
//

import SwiftUI

public struct CalendarViewComponent<Day: View, Header: View, Title: View, Trailing: View>: View {

    // Injected dependencies
    private var startCalendar: Calendar
    private var endCalendar: Calendar
    private var months: [Date] = []
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    
    // Constants
    let spaceName = "scroll"
    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
    private let daysInWeek = 7
    
    public init(
        startCalendar: Calendar,
        endCalendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.startCalendar = startCalendar
        self.endCalendar = endCalendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title

        months = makeMonths()
    }

    public var body: some View {
        
        ChildSizeReader(size: $wholeSize) {
            ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                    VStack {
                        ForEach(months, id: \.self) { month in
                            // Switched from Lazy to VStack to avoid layout glitches
                            VStack(alignment: .leading) {
                                let month = month.startOfMonth(using: startCalendar)
                                let days = makeDays(from: month)
                                
                                Section(header: title(month)) { }
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                                        ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                                    }
                                    Divider()
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                                        ForEach(days, id: \.self) { date in
                                            if startCalendar.isDate(date, equalTo: month, toGranularity: .month) {
                                                content(date)
                                            } else {
                                                trailing(date)
                                            }
                                        }
                                    }
                                }
                                .background(Color(0xf4f4f4))
                                .frame(height: days.count == 42 ? 300 : 270)
                            }
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                            )
                        }
                    )
                    .background(Color(0xf4f4f4))
                    .onPreferenceChange(
                        ViewOffsetKey.self,
                        perform: { value in
                            print("offset: \(value)") // offset: 1270.3333333333333 when User has reached the bottom
                            print("height: \(scrollViewSize.height)") // height: 2033.3333333333333
                            
                            if value <= 0 {
                                print("User has reached the top of the ScrollView.")
                            } else if value >= scrollViewSize.height - wholeSize.height {
                                
                                guard let firstMonth = months.first,
                                      let newDate = startCalendar.date(
                                        byAdding: .month,
                                        value: 1,
                                        to: firstMonth
                                      ) else { return }
                                print("User has reached the bottom of the ScrollView.", newDate)
                            } else {
                                print("not reached.")
                            }
                        }
                    )
                }
            }
            .coordinateSpace(name: spaceName)
            .scrollIndicators(.never)
        }
        .padding([.bottom], 30)
        .background(Color(0xf4f4f4))
    }
}

// MARK: - Conformances

extension CalendarViewComponent: Equatable {
    public static func == (lhs: CalendarViewComponent<Day, Header, Title, Trailing>, rhs: CalendarViewComponent<Day, Header, Title, Trailing>) -> Bool {
        lhs.startCalendar == rhs.startCalendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarViewComponent {
    func makeMonths() -> [Date] {
        guard let yearInterval = startCalendar.dateInterval(of: .year, for: date),
              let yearFirstMonth = startCalendar.dateInterval(of: .month, for: yearInterval.start),
              let yearLastMonth = endCalendar.dateInterval(of: .month, for: yearInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: yearFirstMonth.start, end: yearLastMonth.end)
        return startCalendar.generateDates(for: dateInterval,
                                      matching: startCalendar.dateComponents([.day], from: dateInterval.start))
    }

    func makeDays(from date: Date) -> [Date] {
        guard let monthInterval = startCalendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = startCalendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = endCalendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return startCalendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents) -> [Date] {
            var dates = [dateInterval.start]

            enumerateDates(
                startingAfter: dateInterval.start,
                matching: components,
                matchingPolicy: .nextTime
            ) { date, _, stop in
                guard let date = date else { return }

                guard date < dateInterval.end else {
                    stop = true
                    return
                }

                dates.append(date)
            }

            return dates
        }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize

    let content: () -> Content
    var body: some View {
        ZStack {
            content().background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
