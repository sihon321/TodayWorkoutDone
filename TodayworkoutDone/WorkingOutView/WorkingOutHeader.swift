//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutHeader: View {
    @Binding var workouts: Excercise
    @State private var showingOptions = false
    
    var body: some View {
        VStack {
            HStack {
                Text(workouts.name!).font(.title)
                Spacer()
                Image(systemName: "ellipsis")
                    .onTapGesture {
                        showingOptions = true
                    }
                    .confirmationDialog("select", isPresented: $showingOptions) {
                        Button("취소") {
                            
                        }
                    }
            }
            HStack {
                Text("이전무게")
                    .padding(.leading, 30)
                Spacer()
                Text("횟수")
                Spacer()
                Text("무게")
                    .padding(.trailing, 25)
            }
        }
    }
}

struct WorkingOutHeader_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var excercises = {
        let excercises = Excercise(context: dataController.container.viewContext)
        excercises.name = "name"
        excercises.category = "category"
        return excercises
    }()
    static var previews: some View {
        WorkingOutHeader(workouts: .constant(excercises))
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
