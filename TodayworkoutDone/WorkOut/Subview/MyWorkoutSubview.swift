//
//  MyWorkoutSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct MyWorkoutSubview: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("스쿼트")
                .font(.system(size: 18,
                              weight: .semibold,
                              design: .default))
                .padding(.leading, 15)
            VStack(alignment: .leading) {
                Text("밴치프레스")
                    .font(.system(size: 12,
                                  weight: .light,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(Color(0x939393))
                Text("스쿼트")
                    .padding(.top, 1)
                    .font(.system(size: 12,
                                  weight: .light,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(Color(0x939393))
                Text("데드리프트")
                    .padding(.top, 1)
                    .font(.system(size: 12,
                                  weight: .light,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(Color(0x939393))
                    .padding(.bottom, 1)
            }
            .padding(.top, 1)
        }
        .frame(width: 150,
               height: 120,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}

struct MyWorkoutSubview_Previews: PreviewProvider {
    static var previews: some View {
        MyWorkoutSubview()
            .background(Color.black)
    }
}
