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
        VStack(spacing: 12) {
            Text(workout.name)
                .foregroundColor(.black)
                .font(.system(size: 15))
                .padding(.top, 12)
            Image("default")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 226, maxHeight: 226)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .padding(.horizontal, 40)
    }
}
