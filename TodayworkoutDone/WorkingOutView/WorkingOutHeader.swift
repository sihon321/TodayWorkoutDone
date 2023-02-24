//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutHeader: View {
    @State var title: String = ""
    var body: some View {
        Text(title)
    }
}

struct WorkingOutHeader_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutHeader()
    }
}
