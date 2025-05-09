//
//  MainContentDetailView.swift
//  TodayworkoutDone
//
//  Created by ocean on 3/28/24.
//

import SwiftUI
import Charts

struct MainContentDetailView: View {
    
    struct Time: Identifiable {
        var id = UUID()
        let time: String
        let step: Int
    }
    
    let data: [Time] = [
        Time(time: "오후 1시", step: 120),
        Time(time: "10분", step: 50),
        Time(time: "20분", step: 220),
        Time(time: "30분", step: 320),
        Time(time: "40분", step: 80),
        Time(time: "50분", step: 30),
        Time(time: "오후 2시", step: 10)
    ]
    
    var body: some View {
        VStack {
            Chart(data) {
                BarMark(
                    x: .value("시간", $0.time),
                    y: .value("걸음", $0.step)
                )
                .foregroundStyle(Color.personal)
            }
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   maxHeight: 165)
        }
    }
}

#Preview {
    MainContentDetailView()
}
