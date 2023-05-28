//
//  CustomTabBar.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var currentTab: String
    var bottomEdge: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(["play.fill"], id: \.self) { image in
                TabButton(image: image, currentTab: $currentTab)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, bottomEdge)
        .background(.white)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(currentTab: .constant("play.fill"), bottomEdge: 15)
    }
}

struct TabButton: View {
    var image: String
    @Binding var currentTab: String
    
    var body: some View {
        Button {
            withAnimation{ currentTab = image }
        } label: {
            Image(systemName: image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity)
        }
    }
}
