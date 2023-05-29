//
//  WorkoutCategorySubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutCategorySubview: View {
    var category: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(uiImage: UIImage(named: "woman")!)
                .padding(.leading, 15)
            VStack {
                Text(category)
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

struct WorkoutCategorySubview_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCategorySubview(category: "웨이트")
    }
}
