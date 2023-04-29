//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<Category>
    @State private var isPresentWorkingOutView = false
    @State private var selectionList: [Int] = []
    @State private var selectionWorkouts: [Excercise] = []
    @Binding var isPresentWorkoutView: PresentationMode
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(categories, id: \.self) { category in
                NavigationLink {
                    WorkoutListView(category: category.kor ?? "",
                                    selectionList: $selectionList,
                                    selectionWorkouts: $selectionWorkouts,
                                    isPresentWorkoutView: $isPresentWorkoutView)
                } label: {
                    WorkoutCategorySubview(category: category.kor ?? "")
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
                .fullScreenCover(isPresented: .constant(isPresentWorkingOutView),
                                 content: {
                    WorkingOutView(
                        isPresentWorkingOutView: $isPresentWorkingOutView,
                        isPresentWorkoutView: $isPresentWorkoutView,
                        selectionWorkouts: $selectionWorkouts
                    )
                })
            }
        }
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkoutCategoryView(isPresentWorkoutView: presentationmode)
    }
}
