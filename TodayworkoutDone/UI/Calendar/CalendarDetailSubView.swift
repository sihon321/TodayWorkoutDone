//
//  CalendarDetailSubView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/10/04.
//

import SwiftUI

struct CalendarDetailSubView: View {
    var workoutRoutine: WorkoutRoutineState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(workoutRoutine.name)")
                .font(.title)
            Text("\(workoutRoutine.startDate.formatToKoreanStyle())")
            
            HStack {
                Image(systemName: "timer")
                Text(workoutRoutine.routineTime.convertSecondsToHMS())
                Image(systemName: "flame")
                Text("\(Int(workoutRoutine.calories)) kcal")
            }
            .padding(.bottom, 5)
            
            ForEach(workoutRoutine.routines, id: \.id) { routine in
                Text(routine.workout.name)
                HStack {
                    Image(systemName: "dumbbell")
                    Text("\(String(format: "%.2f", routine.sets.reduce(0) { $0 + $1.weight })) kg")
                    Image(systemName: "flame")
                    Text("\(Int(routine.calories)) kcal")
                }
                ForEach(routine.sets.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1)")
                            .frame(width: 20, height: 20)
                        Text("\(String(format: "%.2f", routine.sets[index].weight)) kg")
                        Text("\(routine.sets[index].reps) reps")
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
    }
}

#Preview {
    CalendarDetailSubView(
        workoutRoutine: WorkoutRoutineState(model: WorkoutRoutine.mockedData)
    )
}
