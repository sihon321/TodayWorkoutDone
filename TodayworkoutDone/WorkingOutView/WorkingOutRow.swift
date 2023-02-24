//
//  WorkingOutRow.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutRow: View {
    @State private var isChecked: Bool = false
    @State var prevWeight: String = ""
    @State var count: String = ""
    @State var wight: String = ""
    
    var body: some View {
        HStack {
            Toggle(prevWeight, isOn: $isChecked)
                .toggleStyle(CheckboxToggleStyle(style: .square))
            Text(count)
            Text(wight)
        }
    }
}

struct WorkingOutRow_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutRow()
    }
}
