//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @State private var isPresentWorkingOutView = false
    @State private var selectionList: [Int] = []
    private var categories: [String] = ["웨이트"]
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(categories, id: \.self) { category in
                NavigationLink {
                    WorkoutListView(category: category,
                                    selectionList: $selectionList)
                } label: {
                    WorkoutCategorySubview(category: category)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectionList.isEmpty {
                Button(action: {
                    isPresentWorkingOutView = true
                }) {
                    Text("Done(\(selectionList.count))")
                }
                .fullScreenCover(isPresented: .constant(isPresentWorkingOutView), content: WorkingOutView.init)
            }
        }
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCategoryView()
    }
}
