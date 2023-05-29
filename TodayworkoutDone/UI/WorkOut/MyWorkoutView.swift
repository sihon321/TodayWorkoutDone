//
//  MyWorkoutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct MyWorkoutView: View {
    private let gridLayout = [GridItem(.flexible())]
    private let sampleData = (1...10).map { index in MyWorkoutSubview() }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("my workout")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sampleData.indices) { _ in
                        MyWorkoutSubview()
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}

struct MyWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MyWorkoutView()
            .background(Color.gray)
    }
}
