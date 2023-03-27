//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListView: View {
    var category: String
    @FetchRequest(sortDescriptors: []) var workoutsList: FetchedResults<Workouts>
    
    var body: some View {
        NavigationView {
            List(workoutsList) { workouts in
                WorkoutListSubview(workouts: workouts)
            }
            .listStyle(.plain)
            .navigationTitle(category)
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView(category: "category")
    }
}
