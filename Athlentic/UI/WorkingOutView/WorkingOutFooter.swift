//
//  WorkingOutFooter.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/11.
//

import SwiftUI

struct WorkingOutFooter: View {
    var body: some View {
        HStack {
            Image(systemName: "plus")
                .foregroundStyle(.white)
            Text("세트 추가")
                .font(.system(size: 17))
                .foregroundStyle(.white)
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .background(Color.grayC3)
        .cornerRadius(10)
    }
}

struct WorkingOutFooter_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutFooter()
    }
}
