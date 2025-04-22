//
//  CalendarDetailSubView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/10/04.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CalendarDetailSubViewReducer {
    @ObservableState
    struct State: Equatable {
        var workoutRoutine: WorkoutRoutineState
    }
    
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}


struct CalendarDetailSubView: View {
    @Bindable var store: StoreOf<CalendarDetailSubViewReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarDetailSubViewReducer>
    
    init(store: StoreOf<CalendarDetailSubViewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(viewStore.workoutRoutine.name)")
                .font(.title)
            Text("\(viewStore.workoutRoutine.startDate.formatToKoreanStyle())")
            
            HStack {
                Image(systemName: "timer")
                Text(viewStore.workoutRoutine.routineTime.convertSecondsToHMS())
                    .padding(.trailing, 10)
                Image(systemName: "flame")
                Text("\(Int(viewStore.workoutRoutine.calories)) kcal")
            }
            .padding(.bottom, 5)
            
            ForEach(viewStore.workoutRoutine.routines, id: \.id) { routine in
                HStack {
                    if let image = UIImage(named: routine.workout.name) ?? UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(maxWidth: 45, maxHeight: 45)
                            .cornerRadius(10)
                    }
                    VStack(alignment: .leading) {
                        Text(routine.workout.name)
                        HStack {
                            Image(systemName: "dumbbell")
                            Text("\(String(format: "%.2f", routine.sets.reduce(0) { $0 + $1.weight })) kg")
                                .padding(.trailing, 10)
                            Image(systemName: "flame")
                            Text("\(Int(routine.calories)) kcal")
                        }
                    }
                }
                .padding(.leading, 5)
                .padding([.top, .bottom], 10)

                VStack {
                    HStack {
                        Text("세트")
                        Spacer()
                        Text("무게")
                        Spacer()
                        Text("횟수")
                        Spacer()
                    }
                    ForEach(routine.sets.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 20, height: 20)
                            Spacer()
                            Text("\(String(format: "%.2f", routine.sets[index].weight)) kg")
                            Spacer()
                            Text("\(routine.sets[index].reps) reps")
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 5)
    }
}

#Preview {
    CalendarDetailSubView(
        store: Store(
            initialState: CalendarDetailSubViewReducer.State(
                workoutRoutine: WorkoutRoutineState(model: WorkoutRoutine.mockedData))
        ) {
            CalendarDetailSubViewReducer()
        }
    )
}
