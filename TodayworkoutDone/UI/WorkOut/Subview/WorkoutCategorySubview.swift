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
            if let image = UIImage(named: category.name) ?? UIImage(named: "default") {
                Image(uiImage: image)
                    .resizable()
                    .frame(maxWidth: 100)
                    .cornerRadius(10)
                    .padding(.leading, 15)
                    .padding([.top, .bottom], 10)
            }
            VStack {
                Text(category.name)
                    .font(.system(size: 18,
                                  weight: .bold,
                                  design: .default))
                    .foregroundColor(.black)
                    .padding(.top, 15)
                Spacer()
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 120,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}
