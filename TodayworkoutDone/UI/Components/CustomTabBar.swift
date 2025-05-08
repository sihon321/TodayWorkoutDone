//
//  CustomTabBar.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CustomTabBarReducer {
    @ObservableState
    struct State: Equatable {
        var bottomEdge: CGFloat
        var tabButton: TabButtonReducer.State
    }
    
    enum Action {
        case tabButton(TabButtonReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabButton(_):
                return .none
            }
        }
    }
}

struct CustomTabBar: View {
    @Bindable var store: StoreOf<CustomTabBarReducer>
    
    let tab: [String] = ["dumbbell.fill", "calendar"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tab.indices, id: \.self) { index in
                TabButton(store: store.scope(state: \.tabButton,
                                             action: \.tabButton),
                          image: tab[index],
                          index: index)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, store.state.bottomEdge)
        .background(.white)
    }
}

@Reducer
struct TabButtonReducer {
    struct TabInfo: Equatable, Hashable {
        var imageName: String
        var index: Int
    }
    @ObservableState
    struct State: Equatable {
        var info: TabInfo
    }
    
    enum Action {
        case setTab(info: TabInfo)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setTab(_):
                return .none
            }
        }
    }
}

struct TabButton: View {
    @Bindable var store: StoreOf<TabButtonReducer>
    
    var image: String
    var index: Int
    
    var body: some View {
        Button {
            store.send(.setTab(info: TabButtonReducer.TabInfo(imageName: image,
                                                              index: index)))
        } label: {
            Image(systemName: image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity)
                .tint(store.state.info.index == index ? Color(.primary) : Color(0x939393))
        }
    }
}
