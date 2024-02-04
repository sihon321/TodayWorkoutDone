//
//  MainContentSubView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/07.
//

import SwiftUI

enum MainContentType {
    case step
    case workoutTime
    case energyBurn
}

struct MainContentSubView: View {
    
    var type: MainContentType
    private let originalTypeHeight: CGFloat = 80
    private let charTypeHeight = 120
    
    private var iconName: String {
        switch type {
        case .step: return "figure.walk"
        case .workoutTime: return "figure.strengthtraining.traditional"
        case .energyBurn: return "flame.fill"
        }
    }
    
    private var headerTitle: String {
        switch type {
        case .step: return "걸음"
        case .workoutTime: return "운동시간"
        case .energyBurn: return "활동"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: iconName)
                Text(headerTitle)
                    .font(.system(size: 15,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, -5)
            }
            .padding([.leading], 15)
            
            HStack(alignment: .firstTextBaseline) {
                switch type {
                case .step:
                    MainContentStepView()
                case .workoutTime:
                    MainContentWorkoutView()
                case .energyBurn:
                    MainContentEnergyBurn()
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

struct MainContentSubView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentSubView(type: .workoutTime)
            .background(Color.black)
    }
}
