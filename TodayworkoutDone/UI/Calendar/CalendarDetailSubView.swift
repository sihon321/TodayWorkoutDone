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
                    .padding(.trailing, 10)
                Image(systemName: "flame")
                Text("\(Int(workoutRoutine.calories)) kcal")
            }
            .padding(.bottom, 5)
            
            ForEach(workoutRoutine.routines, id: \.id) { routine in
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
        workoutRoutine: WorkoutRoutineState(model: WorkoutRoutine.mockedData)
    )
}
