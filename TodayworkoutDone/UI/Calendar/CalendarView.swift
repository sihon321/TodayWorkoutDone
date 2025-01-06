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
        @Presents var destination: Destination.State?
        
        var workoutRoutines: [WorkoutRoutine] = []
        let monthFormatter = DateFormatter(dateFormat: "MMMM YYYY",
                                           calendar: .current)
        let dayFormatter = DateFormatter(dateFormat: "d",
                                         calendar: .current)
        let weekDayFormatter = DateFormatter(dateFormat: "EEEEE",
                                             calendar: .current)
        let fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy",
                                          calendar: .current)
        var todayDate = Date()
        var selectedDate: Date? = nil
        var isPresented = false
        var calendarDetail: CalendarDetailReducer.State?
        
        func filterWorkout(date: Date?) -> [WorkoutRoutine] {
            guard let date = date else { return [] }
            return workoutRoutines.filter({
                $0.date.year == date.year
                && $0.date.month == date.month
                && $0.date.day == date.day
            })
        }
    }
    
    enum Action {
        case loadWorkoutRoutines
        case fetchWorkoutRoutines([WorkoutRoutine])
        case tappedDate(Date)
        
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompleted
        case calendarDetail(CalendarDetailReducer.Action)
        
        case destination(PresentationAction<Destination.Action>)
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        
    }
    
    @Dependency(\.workoutRoutineData) var workoutRoutineContext
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            print(action.description)
            switch action {
            case .loadWorkoutRoutines:
                return .run { send in
                    let workoutRoutines = try workoutRoutineContext.fetchAll()
                    await send(.fetchWorkoutRoutines(workoutRoutines))
                }
            case .fetchWorkoutRoutines(let workoutRoutines):
                state.workoutRoutines = workoutRoutines
                return .none
            case .tappedDate(let date):
                state.selectedDate = date
                return .none
                
            case .setSheet(isPresented: true):
                state.isPresented = false
                state.calendarDetail = nil
                return .run { send in
                  await send(.setSheetIsPresentedDelayCompleted)
                }
                .cancellable(id: CancelID.load)
            case .setSheet(isPresented: false):
              state.isPresented = false
              state.calendarDetail = nil
              return .cancel(id: CancelID.load)
            case .setSheetIsPresentedDelayCompleted:
                if let date = state.selectedDate {
                    state.calendarDetail = CalendarDetailReducer.State(
                        date: date,
                        workoutRoutines: state.filterWorkout(date: date)
                    )
                    state.isPresented = true
                }
                return .none
            case .calendarDetail:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
          Destination.body
        }
    }
}

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarReducer>

    init(store: StoreOf<CalendarReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationView {
            CalendarViewComponent(
                startDate: startDate(viewStore.workoutRoutines),
                store: store,
                content: { date in
                    Button(action: {
                        store.send(.tappedDate(date))
                        if store.state.filterWorkout(date: date).isEmpty == false {
                            store.send(.setSheet(isPresented: true))
                        }
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
                        .foregroundColor(.clear)
                },
                header: { date in
                    Text(viewStore.weekDayFormatter.string(from: date))
                        .fontWeight(.bold)
                },
                title: { date in
                    Text(viewStore.monthFormatter.string(from: date))
                        .font(.title)
                        .padding(.vertical, 8)
                }
            )
            .padding([.leading, .trailing], 15)
            .background(Color(0xf4f4f4))
            .navigationTitle("Calendar")
            .sheet(isPresented: $store.isPresented.sending(\.setSheet)) {
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

private extension CalendarView {
    func startDate(_ workoutRoutines: [WorkoutRoutine]) -> Date {
        let dates = workoutRoutines.compactMap({ $0.date })
        let sortedDates = dates.sorted(by: >)
        return sortedDates.first ?? Date()
    }
    
    func endDate(_ workoutRoutines: [WorkoutRoutine]) -> Date {
        let dates = workoutRoutines.compactMap({ $0.date })
        let sortedDates = dates.sorted(by: <)
        return sortedDates.first ?? Date()
    }
}

extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

extension Date: Identifiable {
    public var id: Date { return self }
}
