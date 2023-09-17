//
//  CalendarDetailView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/09/17.
//

import SwiftUI

struct CalendarDetailView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        })
                    }
                })
        }
    }
}

struct CalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(isPresented: .constant(false))
    }
}
