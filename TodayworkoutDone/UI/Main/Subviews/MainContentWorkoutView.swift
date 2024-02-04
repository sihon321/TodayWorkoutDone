//
//  MainContentWorkoutView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import Combine

struct MainContentWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var exerciseTime: Int = 0
    private var hour: Int {
        return exerciseTime / 60
    }
    private var minute: Int {
        return exerciseTime % 60
    }
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(hour)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
            Text("시간")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
            Text("\(minute)")
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
        .onReceive(appleExerciseTime) { appleExerciseTime in
            self.exerciseTime = appleExerciseTime
        }
    }
}

extension MainContentWorkoutView {
    private var appleExerciseTime: AnyPublisher<Int, Never> {
        injected.interactors.healthkitInteractor.appleExerciseTime()
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }
}

struct MainContentWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentWorkoutView()
    }
}
