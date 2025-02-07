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
            Text("\(workoutRoutine.startDate, format: Date.FormatStyle(date: .numeric, time: .standard))")

            ForEach(workoutRoutine.routines, id: \.id) { routine in
                Text(routine.workout.name)
                if let endDateText = routine.endDate?.description {
                    Text("endDate: " + endDateText)
                    Spacer()
                }
                HStack {
                    Text("\(routine.sets.count) Sets")
                    Text("*")
                    Text("\(routine.sets.compactMap({ $0.reps }).reduce(0, +)) reps")
                }
                ForEach(routine.sets) { sets in
                    if let endDateText = sets.endDate?.description {
                        Text(endDateText)
                    }
                }
                Spacer()
            }
        }
    }
}
