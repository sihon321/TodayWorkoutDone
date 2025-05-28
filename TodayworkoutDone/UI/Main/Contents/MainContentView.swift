//
//  MainContentView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import ComposableArchitecture

struct MainContentView: View {
    enum MainContentType: String, Identifiable {
        case stepCount
        case workoutTime
        case energyBurn
        
        var id: String { self.rawValue }
    }
    
    private let gridLayout = Array(repeating: GridItem(.flexible()),
                                   count: 2)
    private var dataList: [MainContentType] = [
        .stepCount,
        .workoutTime,
        .energyBurn
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: gridLayout, spacing: 10) {
                ForEach(dataList) { data in
                    NavigationLink {
                        MainContentDetailView(store: Store(
                            initialState: MainContentDetailViewReducer.State(contentType: data)
                        ) {
                            MainContentDetailViewReducer()
                        })
                    } label: {
                        MainContentSubView(type: data)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
