//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(\.presentationMode) var presentationmode
    
    @State var text: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(text: $text)
                        .padding(.top, 10)
                    MyWorkoutView()
                        .padding(.top, 10)
                    WorkoutCategoryView()
                        .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationmode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .background(Color.gray)
    }
}
