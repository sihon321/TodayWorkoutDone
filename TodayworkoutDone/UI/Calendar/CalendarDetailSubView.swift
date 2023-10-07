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
            ForEach(workoutRoutine.routines, id: \.id) { routine in
                Text(routine.workouts.name)
                ForEach(routine.sets) { sets in
                    Text("\(sets.weight)")
                }
                .padding([.bottom], 5)
            }
        }
    }
}

struct CalendarDetailSubView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailSubView(workoutRoutine: WorkoutRoutine.mockedData)
    }
}
