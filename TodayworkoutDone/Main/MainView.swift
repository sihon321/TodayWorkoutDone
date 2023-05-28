//
//  MainView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/01.
//

import SwiftUI

struct MainView: View {
    var bottomEdge: CGFloat
    
    var body: some View {
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(bottomEdge: 15)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
    }
}
