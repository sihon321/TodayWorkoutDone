//
//  MainContentStepView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI

struct MainContentStepView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("8,432")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
            Text("걸음")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
    }
}

struct MainContentStepView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentStepView()
    }
}
