//
//  MainContentView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI

struct MainContentView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    private let gridLayout = Array(repeating: GridItem(.flexible()),
                                   count: 2)
    
    var body: some View {
        VStack {
            WeeklyChartView()
            Spacer(minLength: 15)
            LazyVGrid(columns: gridLayout, spacing: 10) {
                MainContentSubView(type: .step)
                MainContentSubView(type: .workoutTime)
                MainContentSubView(type: .energyBurn)
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

