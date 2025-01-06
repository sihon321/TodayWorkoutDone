//
//  WeeklyChartView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import Charts
import ComposableArchitecture

@Reducer
struct WeeklyChart {
    @ObservableState
    struct State: Equatable {
    
    }
    
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

struct WeeklyChartView: View {
    @State private var exerciseTime: Int = 0
    
    struct Weekly: Identifiable {
        var id = UUID()
        let day: String
        let profit: Double
    }
    
    let data: [Weekly] = [
        Weekly(day: "mon", profit: 40.0),
        Weekly(day: "tue", profit: 50.0),
        Weekly(day: "wed", profit: 30.0),
        Weekly(day: "thu", profit: 70.0),
        Weekly(day: "fri", profit: 100.0),
        Weekly(day: "sat", profit: 90.0),
        Weekly(day: "sun", profit: 80.0)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("주당 워크아웃")
            Chart(data) {
                BarMark(
                    x: .value("Weekly", $0.day),
                    y: .value("Profit", $0.profit)
                )
                .foregroundStyle(Color(0xfeb548))
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 165)
        .padding([.leading, .trailing], 15)
        .onAppear {
            
        }
    }
}
