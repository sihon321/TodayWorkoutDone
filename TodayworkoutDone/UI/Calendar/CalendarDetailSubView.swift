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
            Text("\(workoutRoutine.date, format: Date.FormatStyle(date: .numeric, time: .standard))")
            ForEach(workoutRoutine.routines, id: \.id) { routine in
                HStack {
                    Text(routine.workouts.name)
                    Spacer()
                    Text("\(routine.sets.count) Sets")
                    Text("*")
                    Text("\(routine.sets.compactMap({ $0.lab }).reduce(0, +)) lap")
                }
            }
        }
    }
}

struct CalendarDetailSubView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailSubView(workoutRoutine: WorkoutRoutine.mockedData)
    }
}
