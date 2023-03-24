//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    @EnvironmentObject var modelData: DataController
    
    var body: some View {
        NavigationView {
            List {
                ForEach(modelData.exercises) { excercise in
                    WorkingOutSection()
                }
            }
            .navigationTitle("타이틀")
        }
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutView()
    }
}
