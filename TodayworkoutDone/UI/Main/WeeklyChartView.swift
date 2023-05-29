//
//  WeeklyChartView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI

struct WeeklyChartView: View {
    var body: some View {
        VStack {
            Text("Sample Bar Chart")
                .font(.title)
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 165)
        .background(Color.yellow)
    }
}

struct WeeklyChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyChartView()
    }
}
