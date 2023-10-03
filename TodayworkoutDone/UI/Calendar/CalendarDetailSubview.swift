//
//  CalendarDetailSubview.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import SwiftUI

struct CalendarDetailSubview: View {
    var workoutRoutines: [WorkoutRoutine]
    
    var body: some View {
        VStack {
            ForEach(workoutRoutines, id: \.date) { workoutRoutine in
                ForEach(workoutRoutine.routines, id: \.id) { routine in
                    Text(routine.workouts.name)
                    List(routine.sets) { sets in
                        Text("\(sets.weight)")
                    }
                }
            }
        }
    }
}

struct CalendarDetailSubview_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailSubview(workoutRoutines: [])
    }
}
