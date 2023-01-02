//
//  MainContentWorkoutView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI

struct MainContentWorkoutView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("1")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
            Text("시간")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
            Text("18")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .padding(.leading, -5)
            Text("분")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
    }
}

struct MainContentWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentWorkoutView()
    }
}
