//
//  MainContentView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI

struct MainContentView: View {
    private let gridLayout = Array(repeating: GridItem(.flexible()),
                                   count: 2)
    private var dataList: [MainContentType] = [.step, .workoutTime, .energyBurn]
    
    var body: some View {
        VStack {
            WeeklyChartView()
            Spacer(minLength: 15)
            LazyVGrid(columns: gridLayout, spacing: 10) {
                ForEach(dataList) { data in
                    NavigationLink {
                        MainContentDetailView()
                    } label: {
                        MainContentSubView(type: data)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .background(Color.gray)
    }
}

