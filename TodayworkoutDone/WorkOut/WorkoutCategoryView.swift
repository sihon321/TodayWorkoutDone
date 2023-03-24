//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @FetchRequest(sortDescriptors: []) var workouts: FetchedResults<Workouts>
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(workouts) { _ in
                NavigationLink {
                    WorkoutListView()
                } label: {
                    WorkoutCategorySubview()
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCategoryView()
    }
}
