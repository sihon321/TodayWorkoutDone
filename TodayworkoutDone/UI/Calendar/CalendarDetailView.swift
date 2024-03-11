//
//  CalendarDetailView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/17.
//

import SwiftUI

struct CalendarDetailView: View {
    @Binding var isPresented: Bool
    var date: Date
    var workoutRoutines: [WorkoutRoutine]
    
    var body: some View {
        NavigationStack {
            VStack {
                List(filterWorkout(date: date, workoutRoutines), id: \.date) { workoutRoutine in
                    Section(header: Text("\(workoutRoutine.routines.count) exercises")) {
                        CalendarDetailSubView(workoutRoutine: workoutRoutine)
                    }
                }
            }
            .padding([.top], 30)
            .padding([.leading, .bottom, .trailing], 15)
        }
    }
    
    func filterWorkout(date: Date?, _ workoutRoutines: [WorkoutRoutine]) -> [WorkoutRoutine] {
        guard let date = date else { return [] }
        return workoutRoutines.filter({
            $0.date.year == date.year
            && $0.date.month == date.month
            && $0.date.day == date.day
        })
    }
}

struct CalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(isPresented: .constant(false),
                           date: Date(),
                           workoutRoutines: [WorkoutRoutine.mockedData])
    }
}
