//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    @State var isBarPresented: Bool = true
    @State var isPresented = false
    
    var body: some View {
        
        ZStack {
            MainView()
            VStack {
                Spacer()
                Button(action: { self.isPresented.toggle() }) {
                    Text("워크아웃 시작")
                        .frame(minWidth: 0, maxWidth: .infinity - 30)
                        .padding([.top, .bottom], 5)
                        .background(Color(0xfeb548))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0, style: .continuous))
                }
                .padding(.horizontal, 30)
                .fullScreenCover(isPresented: $isPresented, content: WorkoutView.init)
            }
            SlideOverCardView(content: {
                WorkingOutView()
            })
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
