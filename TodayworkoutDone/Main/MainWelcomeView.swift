//
//  MainWelcomeView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI

struct MainWelcomeView: View {
    var body: some View {
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

struct MainWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainWelcomeView()
    }
}
