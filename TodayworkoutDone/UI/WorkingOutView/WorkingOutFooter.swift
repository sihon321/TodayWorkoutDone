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
            Image(systemName: "plus.circle")
            Text("Add Execercise")
        }
    }
}

struct WorkingOutFooter_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutFooter()
    }
}
