//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategoryView: View {
    private var categories: [String] = ["웨이트"]
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(categories, id: \.self) { category in
                NavigationLink {
                    WorkoutListView(category: category)
                } label: {
                    WorkoutCategorySubview(category: category)
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
