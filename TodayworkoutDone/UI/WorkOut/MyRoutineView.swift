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
        var myRoutines: [MyRoutineState] = []
        var selectedRoutine: MyRoutineState?
    }
    
    enum Action {
        case touchedMyRoutine(MyRoutineState)
        case touchedEditMode(MyRoutineState)
        case touchedDelete(MyRoutineState)
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
            Text("My Routine")
                .font(.system(size: 20, weight: .medium))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewStore.myRoutines) { myRoutine in
                        Button(action: {
                            store.send(.touchedMyRoutine(myRoutine))
                        }) {
                            MyWorkoutSubview(
                                store: Store(
                                    initialState: MyWorkoutSubviewReducer.State(myRoutine: myRoutine)
                                ) {
                                    MyWorkoutSubviewReducer()
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
