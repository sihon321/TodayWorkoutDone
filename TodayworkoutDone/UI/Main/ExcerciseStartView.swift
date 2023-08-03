//
//  ExcerciseStartView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import SwiftUI
import Combine

struct ExcerciseStartView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.excerciseStartView)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                injected.appState[\.routing.excerciseStartView.workoutView] = true
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
            .fullScreenCover(isPresented: routingBinding.workoutView) {
                WorkoutView()
                    .inject(injected)
            }
            .offset(y: -15)
        }
        .onAppear {
            injected.appState[\.userData.selectionWorkouts].removeAll()
            injected.appState[\.userData.routines].removeAll()
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
}

extension ExcerciseStartView {
    struct Routing: Equatable {
        var workoutView: Bool = false
    }
}

private extension ExcerciseStartView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.excerciseStartView)
    }
}

struct ExcerciseStartView_Previews: PreviewProvider {
    static var previews: some View {
        ExcerciseStartView()
    }
}

