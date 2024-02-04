//
//  CustomTabBar.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var currentTab: String
    @Binding var currentIndex: Int
    var bottomEdge: CGFloat
    let tab: [String] = ["dumbbell.fill", "calendar"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tab.indices, id: \.self) { index in
                TabButton(image: tab[index],
                          currentTab: $currentTab,
                          currentIndex: $currentIndex,
                          index: index)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, bottomEdge)
        .background(.white)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(currentTab: .constant("dumbbell.fill"), currentIndex: .constant(0), bottomEdge: 15)
    }
}

struct TabButton: View {
    var image: String
    @Binding var currentTab: String
    @Binding var currentIndex: Int
    var index: Int
    
    var body: some View {
        Button {
            withAnimation{ currentTab = image }
            currentIndex = index
        } label: {
            Image(systemName: image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity)
                .tint(currentIndex == index ? Color(0xfeb548) : Color(0x939393))
        }
    }
}
