//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListSubview: View {
    var body: some View {
        HStack {
            Image(uiImage: UIImage(named: "woman")!)
                .resizable()
                .frame(width: 50, height: 50)
                .padding([.leading], 15)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
    }
}

struct WorkoutListSubview_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListSubview()
    }
}
