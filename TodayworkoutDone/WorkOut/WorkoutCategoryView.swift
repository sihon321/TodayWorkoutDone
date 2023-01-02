//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategoryView: View {
    private let gridLayout = [GridItem(.flexible())]
    private let sampleData = (1...10).map { index in MyWorkoutSubview() }
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(sampleData.indices) { _ in
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
