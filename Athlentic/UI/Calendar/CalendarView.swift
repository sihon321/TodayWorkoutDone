//
//  CalendarView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/28.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CalendarReducer {
    @ObservableState
    struct State: Equatable {
        var workoutRoutines: [WorkoutRoutineState] = []
        let monthFormatter = DateFormatter(dateFormat: "MMMM YYYY",
                                           calendar: .current)
        let dayFormatter = DateFormatter(dateFormat: "d",
                                         calendar: .current)
        let weekDayFormatter = DateFormatter(dateFormat: "E",
                                             calendar: .current)
        let fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy",
                                          calendar: .current)
        var todayDate = Date()
        var selectedDate: Date? = nil
        var isSheetPresented = false
        var calendarDetail: CalendarDetailReducer.State?
        
        func filterWorkout(date: Date?) -> [WorkoutRoutineState] {
            guard let date = date else { return [] }
            return workoutRoutines.filter({
                $0.startDate.year == date.year
                && $0.startDate.month == date.month
                && $0.startDate.day == date.day
            })
        }
    }
    
    enum Action {
        case loadWorkoutRoutines
        case fetchWorkoutRoutines([WorkoutRoutineState])
        case tappedDate(Date)
        
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompleted
        case calendarDetail(CalendarDetailReducer.Action)
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Dependency(\.workoutRoutineData) var workoutRoutineContext

    private enum CancelID { case load }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            print(action.description)
            switch action {
            case .loadWorkoutRoutines:
                return .run { send in
                    let workoutRoutines = try workoutRoutineContext.fetchAll()
                        .compactMap { WorkoutRoutineState(model: $0) }
                    await send(.fetchWorkoutRoutines(workoutRoutines))
                }
            case .fetchWorkoutRoutines(let workoutRoutines):
                state.workoutRoutines = workoutRoutines
                return .none
            case .tappedDate(let date):
                guard state.workoutRoutines.contains(where: {
                    $0.startDate.year == date.year
                    && $0.startDate.month == date.month
                    && $0.startDate.day == date.day
                }) else {
                    return .none
                }
                state.selectedDate = date
                return .run { send in
                    await send(.setSheet(isPresented: true))
                }
                .cancellable(id: CancelID.load)
                
            case .setSheet(isPresented: true):
                state.isSheetPresented = true
                return .run { send in
                  await send(.setSheetIsPresentedDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setSheet(isPresented: false):
              state.isSheetPresented = false
              state.calendarDetail = nil
              return .cancel(id: CancelID.load)
                
            case .setSheetIsPresentedDelayCompleted:
                if let date = state.selectedDate {
                    state.calendarDetail = CalendarDetailReducer.State(
                        date: date,
                        workoutRoutines: state.filterWorkout(date: date)
                    )
                }
                return .none
            case .calendarDetail(.calendarDetailSubView(.element(_, action: .destination(.presented(.editWorkoutRoutine(.save(let workoutRoutine))))))):
                if let selectedDate = state.selectedDate,
                   selectedDate.isSameDay(as: workoutRoutine.startDate) {
                    return .send(.loadWorkoutRoutines)
                } else {
                    return .run { send in
                        await send(.loadWorkoutRoutines)
                        await send(.setSheet(isPresented: false))
                    }
                }

            case .calendarDetail(.calendarDetailSubView(.element(_, action: .delete))):
                return .run { send in
                    await send(.loadWorkoutRoutines)
                    await send(.setSheet(isPresented: false))
                }
            case .calendarDetail:
                return .none
            }
        }
        .ifLet(\.calendarDetail, action: \.calendarDetail) {
            CalendarDetailReducer()
        }
    }
}

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarReducer>

    init(store: StoreOf<CalendarReducer>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            CalendarViewComponent(
                workoutRoutines: store.workoutRoutines,
                content: { date in
                    Button(action: {
                        store.send(.tappedDate(date))
                    }) {
                        CalendarViewCell(
                            store: Store(
                                initialState: CalendarCellReducer.State(
                                    dayFormatter: store.dayFormatter,
                                    selectedDate: store.todayDate,
                                    date: date,
                                    workoutRoutines: store.state.filterWorkout(date: date)
                                )
                            ) {
                                CalendarCellReducer()
                            }
                        )
                    }
                },
                trailing: { date in
                    Rectangle()
                        .foregroundStyle(.clear)
                },
                header: { date in
                    Text(store.weekDayFormatter.string(from: date))
                        .fontWeight(.bold)
                },
                title: { date in
                    Text(store.monthFormatter.string(from: date))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .padding(.vertical, 8)
                }
            )
            .padding([.leading, .trailing], 15)
            .background(Color.background)
            .navigationTitle("Calendar")
            .sheet(isPresented: $store.isSheetPresented.sending(\.setSheet)) {
                if let store = store.scope(state: \.calendarDetail, action: \.calendarDetail) {
                  CalendarDetailView(store: store)
                }
            }
        }
        .onAppear {
            store.send(.loadWorkoutRoutines)
        }
    }
}

extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

