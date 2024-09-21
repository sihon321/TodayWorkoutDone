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
        VStack(alignment: .leading) {
            HStack {
                Text(routine.workouts.name)
                    .font(.title2)
                
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            $routine.workoutsType.wrappedValue = .machine
                        }) {
                            Label("머신", systemImage: "pencil")
                        }
                        Button(action: {
                            $routine.workoutsType.wrappedValue = .barbel
                        }) {
                            Label("바벨", systemImage: "pencil")
                        }
                        Button(action: {
                            $routine.workoutsType.wrappedValue = .dumbbel
                        }) {
                            Label("덤벨", systemImage: "pencil")
                        }
                        Button(action: {
                            $routine.workoutsType.wrappedValue = .cable
                        }) {
                            Label("케이블", systemImage: "pencil")
                        }
                    } label: {
                        Text(routine.workoutsType.kor)
                            .padding([.leading, .trailing], 5)
                            .padding([.top, .bottom], 3)
                            .font(.system(size: 11))
                            .foregroundStyle(.black)
                            .background(.gray)
                            .cornerRadius(3.0)
                            .padding(.top, 8)
                    }
                }
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
                Text("횟수")
                    .padding(.leading, 30)
                Text("무게")
                    .padding(.leading, 60)
            }
        }
    }
}
