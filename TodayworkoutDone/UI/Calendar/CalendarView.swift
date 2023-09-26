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
    
    private let startCalendar: Calendar
    private let endCalendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date()

    init(startCalendar: Calendar, endCalendar: Calendar) {
        self.startCalendar = startCalendar
        self.endCalendar = endCalendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: startCalendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: startCalendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: startCalendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: startCalendar)
    }

    var body: some View {
        self.content
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
        Text("").onAppear(perform: loadWorkoutRoutines)
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
                startCalendar: startCalendar,
                endCalendar: endCalendar,
                date: $selectedDate,
                content: { date in
                    Button(action: {
                        isPresented = true
                    }) {
                        CalendarViewCell(calendar: startCalendar,
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
        .padding([.leading, .trailing], 10)
        .background(Color(0xf4f4f4))
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
        CalendarView(startCalendar: .current, endCalendar: .current)
        //            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
