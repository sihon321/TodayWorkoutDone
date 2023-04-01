//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListView: View {
    @FetchRequest(sortDescriptors: []) var workoutsList: FetchedResults<Workouts>
    var category: String
    @Binding var selectionList: [Int]
    
    var body: some View {
        List(Array(zip(workoutsList.indices, workoutsList)), id: \.0) { index, workouts in
            WorkoutListSubview(workouts: workouts,
                               index: index,
                               selectionList: $selectionList)
        }
        .listStyle(.plain)
        .navigationTitle(category)
        .toolbar {
            if !selectionList.isEmpty {
                Button(action: {
                    
                }) {
                    Text("Done(\(selectionList.count))")
                }
            }
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView(category: "category",
                        selectionList: .constant([]))
    }
}
