//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(0..<3) { _ in
                        WorkingOutSection()
                    }
                    .onDelete(perform: delete)
                }
                .toolbar {
                    EditButton()
                }
                .navigationTitle("타이틀")
                .listStyle(.grouped)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    
    static var previews: some View {
        WorkingOutView()
    }
}
