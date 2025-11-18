//
//  AddWorkoutButton.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/17/25.
//

import SwiftUI

struct AddWorkoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 40)
            .foregroundStyle(.white)
            .background(Color.personal)
            .cornerRadius(25)
            .padding([.leading, .trailing], 15)
    }
}
