//
//  MainView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/01.
//

import SwiftUI
import Combine

struct MainView: View {
    var bottomEdge: CGFloat
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    MainWelcomeView()
                    MainContentView()
                        .padding(.bottom, 15 + bottomEdge + 35)
                }
            }
            .background(Color(0xf4f4f4))
        }
    }
}
