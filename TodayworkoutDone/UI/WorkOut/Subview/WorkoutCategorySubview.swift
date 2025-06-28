//
//  WorkoutCategorySubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategorySubview: View {
    var category: WorkoutCategoryState
    
    var body: some View {
        HStack(alignment: .center) {
            Image(category.name)
                .resizable()
                .frame(maxWidth: 100)
                .cornerRadius(10)
                .padding(.leading, 15)
                .padding([.top, .bottom], 10)
            VStack {
                Text(category.name)
                    .font(.system(size: 18,
                                  weight: .bold,
                                  design: .default))
                    .padding(.top, 15)
                    .foregroundStyle(Color.todBlack)
                Spacer()
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 120,
               alignment: .leading)
        .background(Color.contentBackground)
        .cornerRadius(15)
    }
}
