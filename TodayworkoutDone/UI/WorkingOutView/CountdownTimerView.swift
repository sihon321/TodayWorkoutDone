//
//  CountdownTimerView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/21/25.
//

import SwiftUI

struct CountdownTimerView: View {
    @State private var timeRemaining: Int
    @State private var isRunning = false
    let totalTime: Int
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    init(totalTime: Int = 10) {
        self.totalTime = totalTime
        _timeRemaining = State(initialValue: totalTime)
    }
    
    var progress: CGFloat {
        CGFloat(timeRemaining) / CGFloat(totalTime)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                Capsule()
                    .fill(Color.personal.opacity(0.3))
                    .frame(width: 100, height: 20)
                Capsule()
                    .fill(Color.personal)
                    .frame(width: progressBarWidth(), height: 20)
                    .animation(.linear(duration: 1.0), value: timeRemaining)
                Text("\(timeRemaining.secondToHMS)")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isRunning = false
            }
        }
        .onAppear {
            isRunning.toggle()
        }
    }
    
    private func progressBarWidth() -> CGFloat {
        // 전체 너비 기준으로 비율을 조정할 수도 있지만, 여기선 고정값 사용
        let maxWidth: CGFloat = 100
        return maxWidth * progress
    }
}
