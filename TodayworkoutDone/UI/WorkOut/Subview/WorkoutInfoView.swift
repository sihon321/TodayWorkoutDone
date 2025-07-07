//
//  WorkoutInfoView.swift
//  TodayworkoutDone
//
//  Created by ocean on 6/10/25.
//

import SwiftUI

struct WorkoutInfoView: View {
    @Environment(\.popupDismiss) var dismiss
    
    var workout: WorkoutState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .center) {
                    Text(workout.name)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 12)
                        .foregroundStyle(Color.todBlack)
                    
                    if let name = workout.animationName {
                        LoopingVideoPlayerView(videoFileName: name)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text("설명")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.todBlack)
                Text(workout.summary)
                    .font(.system(size: 15))
                    .padding()
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundStyle(Color.todBlack)
                
                Text("운동 방법")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.todBlack)
                Text(workout.instructions.enumerated().map({ return "\($0.offset + 1). \($0.element)"  }).joined(separator: "\n"))
                    .font(.system(size: 15))
                    .padding()
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundStyle(Color.todBlack)
                
                Text("주의사항")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.todBlack)
                Text(workout.cautions.joined(separator: "\n"))
                    .font(.system(size: 15))
                    .padding()
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundStyle(Color.todBlack)
                
                Text("운동 강도 및 난이도")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.todBlack)
                VStack(alignment: .leading) {
                    let stars = (0..<workout.difficulty).map { _ in "⭐️" }.joined()
                    Text("난이도: \(stars)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.todBlack)
                    Text("METs: \(String(format: "%.1f", workout.mets))")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.todBlack)
                    Text("예상 칼로리 소모: 약 \(workout.caloriesPer30Min)kcal/30분")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.todBlack)
                    Text("적절한 반복/세트 수: \(workout.recommendedReps)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.todBlack)
                }
                .padding()
                .frame(maxWidth: .infinity,
                       alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(15)
        .background(Color.contentBackground)
        .cornerRadius(15)
        .padding(20)
    }
}

#Preview {
    WorkoutInfoView(workout: WorkoutState(model: Workout.mockedData[1]))
}
