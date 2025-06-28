//
//  CalendarDetailView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/17.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
struct CalendarDetailReducer {
    @ObservableState
    struct State: Equatable {
        var date: Date
        var calendarDetailSubView: IdentifiedArrayOf<CalendarDetailSubViewReducer.State> = []
        
        init(date: Date, workoutRoutines: [WorkoutRoutineState]) {
            self.date = date
            self.calendarDetailSubView = IdentifiedArrayOf(
                uniqueElements: workoutRoutines.compactMap {
                    CalendarDetailSubViewReducer.State(
                        workoutRoutine: $0
                    )
                }
            )
        }
    }
    
    enum Action {
        case updateWorkoutRoutines
        case calendarDetailSubView(IdentifiedActionOf<CalendarDetailSubViewReducer>)
    }
    
    @Dependency(\.workoutRoutineData) var workoutRoutineContext
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .calendarDetailSubView(.element(_, action: .destination(.presented(.editWorkoutRoutine(.save))))):
                return .send(.updateWorkoutRoutines)
            case .updateWorkoutRoutines:
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: state.date)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    let descriptor = FetchDescriptor<WorkoutRoutine>(
                        predicate: #Predicate {
                            $0.startDate >= startOfDay && $0.startDate < endOfDay
                        }
                    )
                    let workoutRoutines = try workoutRoutineContext.fetch(descriptor)
                    let updatedWorkoutRoutines = workoutRoutines.compactMap {
                        WorkoutRoutineState(model: $0)
                    }
                    state.calendarDetailSubView = IdentifiedArrayOf(
                        uniqueElements: updatedWorkoutRoutines.compactMap {
                            CalendarDetailSubViewReducer.State(
                                workoutRoutine: $0
                            )
                        }
                    )
                    
                } catch {
                    print(error.localizedDescription)
                }

                return .none
            case .calendarDetailSubView(.element(_, action: .delete)):
                
                return .send(.updateWorkoutRoutines)
            case .calendarDetailSubView:
                return .none
            }
        }
        .forEach(\.calendarDetailSubView, action: \.calendarDetailSubView) {
            CalendarDetailSubViewReducer()
        }
    }
}

struct CalendarDetailView: View {
    @Bindable var store: StoreOf<CalendarDetailReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarDetailReducer>
    
    init(store: StoreOf<CalendarDetailReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ScrollView {
            ForEach(store.scope(state: \.calendarDetailSubView,
                                action: \.calendarDetailSubView)) { store in
                CalendarDetailSubView(store: store)
            }
        }
        .padding([.top], 30)
        .padding([.leading, .trailing], 15)
    }
}

#Preview {
    CalendarDetailView(
        store: Store(
            initialState: CalendarDetailReducer.State(
                date: Date(),
                workoutRoutines: [WorkoutRoutineState(model: WorkoutRoutine.mockedData),
                                  WorkoutRoutineState(model: WorkoutRoutine.mockedData)])
        ) {
            CalendarDetailReducer()
        }
    )
}
