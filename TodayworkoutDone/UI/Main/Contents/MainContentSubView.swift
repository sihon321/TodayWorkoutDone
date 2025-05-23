//
//  MainContentSubView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/07.
//

import SwiftUI
import ComposableArchitecture

struct MainContentSubView: View {
    var type: MainContentView.MainContentType
    private let originalTypeHeight: CGFloat = 80
    private let charTypeHeight = 120
    
    private var iconName: String {
        switch type {
        case .stepCount: return "figure.walk"
        case .workoutTime: return "figure.strengthtraining.traditional"
        case .energyBurn: return "flame.fill"
        }
    }
    
    private var headerTitle: String {
        switch type {
        case .stepCount: return "걸음"
        case .workoutTime: return "운동시간"
        case .energyBurn: return "활동"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: iconName)
                    .foregroundStyle(.black)
                Text(headerTitle)
                    .font(.system(size: 15,
                                  weight: .semibold,
                                  design: .default))
                    .foregroundStyle(.black)
                    .padding(.leading, -5)
            }
            .padding([.leading], 15)
            
            HStack(alignment: .firstTextBaseline) {
                switch type {
                case .stepCount:
                    MainContentStepView(
                        store: Store(initialState: StepFeature.State()) {
                            StepFeature()
                        }
                    )
                case .workoutTime:
                    MainContentWorkoutView(
                        store: Store(initialState: ExerciseTimeFeature.State()) {
                            ExerciseTimeFeature()
                        }
                    )
                case .energyBurn:
                    MainContentEnergyBurn(
                        store: Store(initialState: EnergyBurnFeature.State()) {
                            EnergyBurnFeature()
                        }
                    )
                }
            }
            .padding(.leading, 15)
            .padding([.top, .bottom], 5)
        } 
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: originalTypeHeight,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}
