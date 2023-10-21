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
    @Binding var routingState: MyWorkoutView.Routing
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(myRoutine.name)
                    .font(.system(size: 18,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, 15)
                Spacer()
                Menu {
                    Button(action: {
                        injected.appState[\.routing.myWorkoutView.makeWorkoutView] = true
                    }) {
                        Label("편집", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .contentShape(Rectangle())
                        .padding(.trailing, 15)
                }
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
    }
}

struct MyWorkoutSubview_Previews: PreviewProvider {
    static var previews: some View {
        MyWorkoutSubview(myRoutine: MyRoutine(name: "test", routines: []),
                         routingState: .constant(MyWorkoutView.Routing()))
            .background(Color.black)
    }
}
