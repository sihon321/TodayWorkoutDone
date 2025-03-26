//
//  CalendarDetailSubView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/10/04.
//

import SwiftUI

struct CalendarDetailSubView: View {
    var workoutRoutine: WorkoutRoutine
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(workoutRoutine.name)")
                .font(.title)
            Text("\(workoutRoutine.startDate.formatToKoreanStyle())")
                .font(.caption)
            
            HStack {
                Image(systemName: "timer")
                Text(workoutRoutine.routineTime.convertSecondsToHMS())
                Image(systemName: "flame")
                Text("\(Int(workoutRoutine.calories)) kcal")
            }
            
            ForEach(workoutRoutine.routines, id: \.id) { routine in
                Text(routine.workout.name)
                HStack {
                    Image(systemName: "flame")
                    Text("\(Int(routine.calories)) kcal")
                }
                ForEach(routine.sets.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1)")
                            .frame(width: 20, height: 20)
                            .padding(3)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .padding(.leading, 1)
                            .padding(.trailing, 5)
                        Text("\(String(format: "%.2f", routine.sets[index].weight)) kg")
                        Text("\(routine.sets[index].reps) reps")
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CalendarDetailSubView(workoutRoutine: WorkoutRoutine.mockedData)
}
