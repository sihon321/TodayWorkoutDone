//
//  WorkingOutRow.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutRow: View {
    @Binding var sets: Sets
    @Binding var editMode: EditMode
    @State private var isChecked: Bool = false
    @State private var prevWeight: String = ""
    @State private var count: String = ""
    @State private var weight: String = ""
    
    var body: some View {
        HStack {
            Toggle("", isOn: $isChecked)
                .toggleStyle(CheckboxToggleStyle(style: .square))
            Spacer()
            if editMode == .active {
                TextField("count", text: $count)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(5)
            } else {
                Text(count)
            }
            Spacer()
            Text("\(sets.prevLab)")
                .frame(minWidth: 40)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
            Spacer()
            if editMode == .active {
                TextField("weight", text: $weight)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(5)
            } else {
                Text(weight)
            }
            Spacer()
            Text(String(format: "%.1f", sets.prevWeight))
                .frame(minWidth: 40)
                .background(Color(uiColor: .secondarySystemFill))
                .cornerRadius(5)
        }
    }
}

struct WorkingOutRow_Previews: PreviewProvider {
    static var sets = {
        return Sets()
    }()
    static var previews: some View {
        WorkingOutRow(sets: .constant(sets),
                      editMode: .constant(.active))
    }
}
