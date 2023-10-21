//
//  MyWorkoutSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct MyWorkoutSubview: View {
    @Environment(\.injected) private var injected: DIContainer
    var myRoutine: MyRoutine
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.myWorkoutSubview)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(myRoutine.name)
                    .font(.system(size: 18,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, 15)
                Spacer()
                Button(action: {
                    injected.appState[\.routing.myWorkoutSubview.makeWorkoutView] = true
                }) {
                    Image(systemName: "ellipsis")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(myRoutine: .constant(MyRoutine(name: myRoutine.name,
                                                                   routines: myRoutine.routines)))
                })
                .padding(.trailing, 15)
            }
            VStack(alignment: .leading) {
                ForEach(myRoutine.routines) { routine in
                    Text(routine.workouts.name)
                        .font(.system(size: 12,
                                      weight: .light,
                                      design: .default))
                        .padding(.leading, 15)
                        .foregroundColor(Color(0x939393))
                }
            }
            .padding(.top, 1)
        }
        .frame(width: 150,
               height: 120,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
}

extension MyWorkoutSubview {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
    }
}

extension MyWorkoutSubview {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.myWorkoutSubview)
    }
}

struct MyWorkoutSubview_Previews: PreviewProvider {
    static var previews: some View {
        MyWorkoutSubview(myRoutine: MyRoutine(name: "test", routines: []))
            .background(Color.black)
    }
}
