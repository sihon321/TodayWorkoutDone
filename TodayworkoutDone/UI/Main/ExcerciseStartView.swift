//
//  ExcerciseStartView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import SwiftUI

struct ExcerciseStartView: View {
    @Environment(\.injected) private var injected: DIContainer
    @Binding var isPresented: Bool
    @Binding var isWorkingOut: Bool
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.excerciseStartView)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                injected.appState[\.routing.excerciseStartView.workoutView].toggle()
            }) {
                Text("워크아웃 시작")
                    .frame(minWidth: 0, maxWidth: .infinity - 30)
                    .padding([.top, .bottom], 5)
                    .background(Color(0xfeb548))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0,
                                                style: .continuous))
            }
            .padding(.horizontal, 30)
            .fullScreenCover(isPresented: routingBinding.workoutView, onDismiss: {
                isWorkingOut = injected.appState[\.routing.excerciseStartView.workoutView]
            }) {
                WorkoutView(isPresented: routingBinding.workoutView)
            }
            .offset(y: -15)
        }
    }
}

extension ExcerciseStartView {
    struct Routing: Equatable {
        var workoutView: Bool = false
    }
}

struct ExcerciseStartView_Previews: PreviewProvider {
    static var previews: some View {
        ExcerciseStartView(isPresented: .constant(false),
                           isWorkingOut: .constant(false))
    }
}

