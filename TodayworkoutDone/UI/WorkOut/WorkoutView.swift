//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct WorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var routingState: Routing = .init()
    @State private var text: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(text: $text)
                        .padding(.top, 10)
                    MyWorkoutView()
                        .padding(.top, 10)
                    WorkoutCategoryView()
                        .inject(injected)
                        .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        injected.appState[\.routing.excerciseStartView.workoutView] = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
}

extension WorkoutView {
    struct Routing: Equatable {
        var workoutCategoryView: Bool = false
    }
}

private extension WorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutView)
    }
}


struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .background(Color.gray)
    }
}
