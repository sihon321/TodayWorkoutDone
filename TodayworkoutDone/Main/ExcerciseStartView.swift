//
//  ExcerciseStartView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import SwiftUI

struct ExcerciseStartView: View {
    @Binding var isBarPresented: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: { self.isPresented.toggle() }) {
                Text("워크아웃 시작")
                    .frame(minWidth: 0, maxWidth: .infinity - 30)
                    .padding([.top, .bottom], 5)
                    .background(Color(0xfeb548))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0,
                                                style: .continuous))
            }
            .padding(.horizontal, 30)
            .fullScreenCover(isPresented: $isPresented,
                             content: WorkoutView.init)
        }
    }
}

struct ExcerciseStartView_Previews: PreviewProvider {
    static var previews: some View {
        ExcerciseStartView(isBarPresented: .constant(true),
                           isPresented: .constant(false))
    }
}

