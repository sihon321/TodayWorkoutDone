//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutHeader: View {
    @State private var title: String = "title"
    @State private var showingOptions = false
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: {
                showingOptions = true
            }, label: {
                Image(systemName: "ellipsis")
            })
            .confirmationDialog("select", isPresented: $showingOptions) {
                Button("취소") {

                }
            }
        }
    }
}

struct WorkingOutHeader_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutHeader()
    }
}
