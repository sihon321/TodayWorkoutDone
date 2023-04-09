//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutHeader: View {
    @Binding var workouts: Excercise
    @State private var showingOptions = false
    
    var body: some View {
        VStack {
            HStack {
                Text(workouts.name!).font(.title)
                Spacer()
                Button(action: {
                    showingOptions = true
                }, label: {
                    Image(systemName: "ellipsis")
                })
                .confirmationDialog("select", isPresented: $showingOptions) {
                    Button("취소") {
                        
                    }
                }
            }
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
    static var previews: some View {
        WorkingOutHeader(workouts: .constant(Excercise()))
    }
}
