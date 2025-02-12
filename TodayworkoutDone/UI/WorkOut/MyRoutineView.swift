//
//  MyWorkoutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MyRoutineReducer {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
        var myRoutines: [MyRoutine] = []
        var selectedRoutine: MyRoutine?
    }
    
    enum Action {
        case touchedMyRoutine(MyRoutine)
        case touchedEditMode(MyRoutine)
        case touchedDelete(MyRoutine)
    }
}

struct MyRoutineView: View {
    @Bindable var store: StoreOf<MyRoutineReducer>
    @ObservedObject var viewStore: ViewStoreOf<MyRoutineReducer>
    
    init(store: StoreOf<MyRoutineReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("my Routine")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewStore.myRoutines) { myRoutine in
                        Button(action: {
                            store.send(.touchedMyRoutine(myRoutine))
                        }) {
                            MyWorkoutSubview(store: store, myRoutine: myRoutine)
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
