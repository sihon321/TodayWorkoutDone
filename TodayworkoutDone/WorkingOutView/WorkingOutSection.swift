//
//  WorkingOutSection.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutSection: View {
    var body: some View {
        Section {
            WorkingOutRow()
        } header: {
            WorkingOutHeader()
        }
    }
}

struct WorkingOutSection_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutSection()
    }
}
