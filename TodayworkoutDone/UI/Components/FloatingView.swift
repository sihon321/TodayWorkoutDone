//
//  FloatingView.swift
//  TodayworkoutDone
//
//  Created by ocean on 4/29/25.
//

import SwiftUI

struct FloatingButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 6)
        }
    }
}
