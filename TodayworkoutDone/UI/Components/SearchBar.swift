//
//  SearchBar.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchReducer {
    @ObservableState
    struct State: Equatable {
        var keyword: String = ""
    }
    
    enum Action: Equatable {
        case search(keyword: String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                return .none
            }
        }
    }
}

struct SearchBar: View {
    @Bindable var store: StoreOf<SearchReducer>
    @ObservedObject var viewStore: ViewStoreOf<SearchReducer>
    @State private var isEditing = false
    
    init(store: StoreOf<SearchReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            TextField(
                "search",
                text: viewStore.binding(
                    get: { $0.keyword },
                    send: { SearchReducer.Action.search(keyword: $0) }
                )
            )
            .padding(7)
            .padding(.horizontal, 25)
            .background(.white)
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .padding(.horizontal, 10)
            .onTapGesture {
                self.isEditing = true
            }
        }
    }
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(text: .constant(""))
//            .background(.gray)
//    }
//}
