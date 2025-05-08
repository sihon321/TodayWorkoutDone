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
            Text("세트 추가")
                .font(.system(size: 17))
        }
        .frame(height: 25)
        .frame(maxWidth: .infinity)
        .background(Color.gray88)
        .padding(.vertical, 5)
        .cornerRadius(5)
    }
}

struct WorkingOutFooter_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutFooter()
    }
}
