//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    var body: some View {
        NavigationView {
            List {
                WorkingOutSection()
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
