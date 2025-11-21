//
//  WorkoutInfoView.swift
//  TodayworkoutDone
//
//  Created by ocean on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkoutInfoFeature {
    @ObservableState
    struct State: Equatable {
        var workout: WorkoutState
    }
    
    enum Action {
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}

struct WorkoutInfoView: View {
    @Bindable var store: StoreOf<WorkoutInfoFeature>

    init(store: StoreOf<WorkoutInfoFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .center) {
                        Text(store.workout.name)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top, 12)
                            .foregroundStyle(Color.todBlack)
                        
                        if let name = store.workout.animationName,
                           let view = LoopingVideoPlayerView(videoFileName: name) {
                            view
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("설명")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.todBlack)
                    Text(store.workout.summary)
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
                    Text(store.workout.instructions.enumerated().map({ return "\($0.offset + 1). \($0.element)"  }).joined(separator: "\n"))
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
                    Text(store.workout.cautions.joined(separator: "\n"))
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
                        let stars = (0..<store.workout.difficulty).map { _ in "⭐️" }.joined()
                        Text("난이도: \(stars)")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.todBlack)
                        Text("METs: \(String(format: "%.1f", store.workout.mets))")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.todBlack)
                        Text("예상 칼로리 소모: 약 \(store.workout.caloriesPer30Min)kcal/30분")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.todBlack)
                        Text("적절한 반복/세트 수: \(store.workout.recommendedReps)")
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
            .padding(.horizontal, 15)
            .background(Color.contentBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        store.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .tint(Color.todBlack)
        }
    }
}

#Preview {
    WorkoutInfoView(
        store: Store(
            initialState: WorkoutInfoFeature.State(
                workout: WorkoutState(
                    model: Workout.mockedData[1]
                )
            )
        ) {
        WorkoutInfoFeature()
    })
}
