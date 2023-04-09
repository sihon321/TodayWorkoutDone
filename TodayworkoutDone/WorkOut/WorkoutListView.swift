//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListView: View {
    @FetchRequest(sortDescriptors: []) var workoutsList: FetchedResults<Workouts>
    @State private var isPresentWorkingOutView = false
    var category: String
    @Binding var selectionList: [Int]
    @Binding var selectionWorkouts: [Excercise]
    
    var body: some View {
        List(Array(zip(workoutsList.indices, workoutsList)), id: \.0) { index, workouts in
            WorkoutListSubview(workouts: workouts,
                               index: index,
                               selectionList: $selectionList,
                               selectionWorkouts: $selectionWorkouts)
        }
        .listStyle(.plain)
        .navigationTitle(category)
        .toolbar {
            if !selectionList.isEmpty {
                Button(action: {
                    isPresentWorkingOutView = true
                }) {
                    Text("Done(\(selectionList.count))")
                }
                .fullScreenCover(isPresented: .constant(isPresentWorkingOutView),
                                 content: {
                    WorkingOutView(selectionWorkouts: $selectionWorkouts)
                })
            }
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView(category: "category",
                        selectionList: .constant([]),
                        selectionWorkouts: .constant([]))
    }
}
