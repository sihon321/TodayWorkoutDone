//
//  MainView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/01.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MainReducer {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        
    }
}

struct MainView: View {
    var bottomEdge: CGFloat
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    welcomeView()
                    WeeklyChartView()
                    Spacer(minLength: 15)
                    MainContentView()
                        .padding(.bottom, 15 + bottomEdge + 35)
                }
            }
            .background(Color(0xf4f4f4))
        }
    }
    
    private func welcomeView() -> some View {
        VStack(alignment: .leading) {
            Text("Hello,")
            Text("Sihoon")
        }
        .font(.system(size: 30,
                      weight: .bold,
                      design: .default))
        .padding([.leading, .top], 20)
    }
}
