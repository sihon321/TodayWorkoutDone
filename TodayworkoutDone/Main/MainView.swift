//
//  MainView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/01.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                MainWelcomeView()
                MainContentView()
            }
        }
        .background(Color(0xf4f4f4))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
    }
}
