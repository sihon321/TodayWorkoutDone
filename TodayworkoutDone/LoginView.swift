//
//  LoginView.swift
//  TodayworkoutDone
//
//  Created by oceano on 3/2/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLogin: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Image(.splash)
                .resizable()
                .scaledToFit()
                .frame(width: 242, height: 100)
                .padding(.bottom, 150)
            Button(action: {
                isLogin = true
            }) {
                Text("Google Login")
            }
            .frame(width: 330, height: 55)
            .background(Color.white)
            .cornerRadius(10)
            
            Button(action: {
                isLogin = true
            }) {
                Text("Apple Login")
            }
            .frame(width: 330, height: 55)
            .background(Color.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(0xFEB548))
        .edgesIgnoringSafeArea(.all)
    }
}
