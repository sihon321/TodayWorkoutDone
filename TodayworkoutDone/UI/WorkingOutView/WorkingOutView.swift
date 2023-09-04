//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var editMode: EditMode = .inactive
    @Binding var isCloseWorking: Bool
    @Binding var hideTabValue: CGFloat
    @Binding var isSavedAlert: Bool
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    private var routines: [Routine] {
        injected.appState[\.userData.routines]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(routines) { routine in
                    WorkingOutSection(
                        routine: .constant(routine),
                        editMode: $editMode
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        injected.appState[\.routing.homeView.workingOutView] = false
                        isCloseWorking = true
                        hideTabValue = 0.0
                        isSavedAlert = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
            .navigationTitle("타이틀")
            .listStyle(.grouped)
            .padding([.bottom], 60)
        }
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkingOutView(isCloseWorking: .constant(false), hideTabValue: .constant(0.0), isSavedAlert: .constant(false))
    }
}
