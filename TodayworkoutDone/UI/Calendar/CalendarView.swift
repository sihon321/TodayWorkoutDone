//
//  CalendarView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/28.
//

import SwiftUI

struct CalendarView: View {
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date()

    //    @FetchRequest(sortDescriptors: []) var fixtures: FetchedResults<Fixture>

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        VStack {
            CalendarViewComponent(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    VStack {
                        Button(action: { selectedDate = date }) {
                            Text(dayFormatter.string(from: date))
                                .padding(8)
                                .foregroundColor(calendar.isDateInToday(date) ? Color.white : .primary)
                                .background(
                                    calendar.isDateInToday(date) ? Color.green
                                    : calendar.isDate(date, inSameDayAs: selectedDate) ? .gray
                                    : .clear
                                )
                                .frame(maxHeight: .infinity)
                                .contentShape(Rectangle())
                                .cornerRadius(7)
                        }

                        if (isFasting(on: date)) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(23),
                                        y: CGFloat(35))
                        }
                    }

                },
                trailing: { date in
                    Button(action: { selectedDate = date }) {
                        Text(dayFormatter.string(from: date))
                            .padding(8)
                            .foregroundColor(calendar.isDateInToday(date) ? .white : .clear)
                            .background(
                                calendar.isDateInToday(date) ? .green
                                : calendar.isDate(date, inSameDayAs: selectedDate) ? .gray
                                : .clear
                            )
                            .cornerRadius(7)
                    }
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
    }

    func isFasting(on: Date) -> Bool {

        //        for fixture in fixtures {
        //            if calendar.isDate(date, inSameDayAs: fixture.date ?? Date()) {
        //                return true
        //            }
        //        }

        return false
    }
}

// MARK: - Component

public struct CalendarViewComponent<Day: View, Header: View, Title: View, Trailing: View>: View {

    // Injected dependencies
    private var calendar: Calendar
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

    //    @FetchRequest var fixtures: FetchedResults<Fixture>

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title

        months = makeMonths()
    }

    public var body: some View {
        ChildSizeReader(size: $wholeSize){
            ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                    VStack {
                        ForEach(months, id: \.self) { month in
                            // Switched from Lazy to VStack to avoid layout glitches
                            VStack(alignment: .leading) {
                                let month = month.startOfMonth(using: calendar)
                                let days = makeDays(from: month)

                                Section(header: title(month)) { }
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                                        ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                                    }
                                    Divider()
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                                        ForEach(days, id: \.self) { date in
                                            if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                                content(date)
                                            } else {
                                                trailing(date)
                                            }
                                        }
                                    }
                                }
                                .frame(height: days.count == 42 ? 300 : 270)
                                .background(Color.white)
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
                    .onPreferenceChange(
                        ViewOffsetKey.self,
                        perform: { value in
                            print("offset: \(value)") // offset: 1270.3333333333333 when User has reached the bottom
                            print("height: \(scrollViewSize.height)") // height: 2033.3333333333333

                            if value <= 0 {
                                print("User has reached the top of the ScrollView.")
                            } else if value >= scrollViewSize.height - wholeSize.height {

                                guard let firstMonth = months.first,
                                      let newDate = calendar.date(
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
        //        .onChange(
        //            of: scrollViewSize,
        //            perform: { value in
        //                print(value)
        //            }
        //        )
    }
}

// MARK: - Conformances

extension CalendarViewComponent: Equatable {
    public static func == (lhs: CalendarViewComponent<Day, Header, Title, Trailing>, rhs: CalendarViewComponent<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarViewComponent {
    func makeMonths() -> [Date] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: date),
              let yearFirstMonth = calendar.dateInterval(of: .month, for: yearInterval.start),
              let yearLastMonth = calendar.dateInterval(of: .month, for: yearInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: yearFirstMonth.start, end: yearLastMonth.end)
        return calendar.generateDates(for: dateInterval,
                                      matching: calendar.dateComponents([.day], from: dateInterval.start))
    }

    func makeDays(from date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
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

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
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

// MARK: - Previews

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(calendar: .current)
        //            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
