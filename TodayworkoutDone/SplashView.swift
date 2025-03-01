//
//  SplashView.swift
//  TodayworkoutDone
//
//  Created by oceano on 3/1/25.
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            Color(0xFEB548)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Image(.splash)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 242, height: 100)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
