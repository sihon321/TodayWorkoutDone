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
    @State private(set) var workoutRoutines: Loadable<LazyList<WorkoutRoutine>> = .notRequested
    
    @State private var isPresented = false
    
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var todayDate = Self.now
    @State private var selectedDate: Date? = nil
    private static var now = Date()

    init() {
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: .current)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: .current)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: .current)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: .current)
    }

    var body: some View {
        self.content
            .onAppear(perform: loadWorkoutRoutines)
    }
    
    @ViewBuilder private var content: some View {
        switch workoutRoutines {
        case .notRequested:
            notRequestedView
        case .isLoading(let last, _):
            loadingView(last)
        case .loaded(let routines):
            loadedView(routines)
        case .failed(let error):
            failedView(error)
        }
    }
}

private extension CalendarView {
    func loadWorkoutRoutines() {
        injected.interactors.routineInteractor
            .load(workoutRoutines: $workoutRoutines)
    }
}

// MARK: - Loading Content

private extension CalendarView {
    var notRequestedView: some View {
        Text("")
    }
    
    func loadingView(_ previouslyLoaded: LazyList<WorkoutRoutine>?) -> some View {
        if let workoutRoutines = previouslyLoaded {
            return AnyView(loadedView(workoutRoutines))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadWorkoutRoutines()
        })
    }
}

private extension CalendarView {
    func loadedView(_ workoutRoutines: LazyList<WorkoutRoutine>) -> some View {
        NavigationView {
            CalendarViewComponent(
                startDate: startDate(workoutRoutines),
                date: $todayDate,
                content: { date in
                    let filteredWorkout = filterWorkout(date: date, workoutRoutines.array())
                    Button(action: {
                        if !filteredWorkout.isEmpty {
                            selectedDate = date
                        }
                        isPresented = true
                    }) {
                        CalendarViewCell(
                            dayFormatter: dayFormatter,
                            selectedDate: $todayDate,
                            date: date,
                            workoutRoutines: filteredWorkout
                        )
                    }
                    .sheet(item: $selectedDate) { selectedDate in
                        CalendarDetailView(
                            isPresented: $isPresented,
                            date: selectedDate,
                            workoutRoutines: workoutRoutines.array()
                        )
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
            .padding([.leading, .trailing], 15)
            .background(Color(0xf4f4f4))
            .navigationTitle("Calendar")
        }
        
    }
    
    func startDate(_ workoutRoutines: LazyList<WorkoutRoutine>) -> Date {
        let dates = workoutRoutines.array().compactMap({ $0.date })
        let sortedDates = dates.sorted(by: >)
        return sortedDates.first ?? Date()
    }
    
    func endDate(_ workoutRoutines: LazyList<WorkoutRoutine>) -> Date {
        let dates = workoutRoutines.array().compactMap({ $0.date })
        let sortedDates = dates.sorted(by: <)
        return sortedDates.first ?? Date()
    }
    
    func filterWorkout(date: Date?, _ workoutRoutines: [WorkoutRoutine]) -> [WorkoutRoutine] {
        guard let date = date else { return [] }
        return workoutRoutines.filter({
            $0.date.year == date.year
            && $0.date.month == date.month
            && $0.date.day == date.day
        })
    }
}

extension DateFormatter {
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
        CalendarView()
        //            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif

extension Date: Identifiable {
    public var id: Date { return self }
}
