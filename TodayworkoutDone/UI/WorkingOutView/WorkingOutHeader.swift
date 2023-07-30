//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutHeader: View {
    @Binding var routine: Routine
    @State private var showingOptions = false
    
    var body: some View {
        VStack {
            HStack {
                Text(routine.workouts.name)
                    .font(.title)
                Spacer()
                Image(systemName: "ellipsis")
                    .onTapGesture {
                        showingOptions = true
                    }
                    .confirmationDialog("select", isPresented: $showingOptions) {
                        Button("삭제") {
                            
                        }
                    }
            }
            .padding()
            HStack {
                Text("이전무게")
                    .padding(.leading, 30)
                Spacer()
                Text("횟수")
                Spacer()
                Text("무게")
                    .padding(.trailing, 25)
            }
        }
    }
}

struct WorkingOutHeader_Previews: PreviewProvider {
    static var routine = {
        return Routine(workouts: Workouts(name: "test",
                                          category: "test_category",
                                          target: "test_target"))
    }()
    static var previews: some View {
        WorkingOutHeader(routine: .constant(routine))
    }
}
