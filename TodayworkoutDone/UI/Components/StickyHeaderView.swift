//
//  StickyHeaderView.swift
//  TodayworkoutDone
//
//  Created by oceano on 2/28/25.
//

import SwiftUI

struct StickyHeaderView: View {
    let index: Int
    let title: String
    
    @Binding var topHeaderIndex: Int?
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: StickyHeaderPreferenceKey.self,
                                    value: [StickyHeaderData(index: index, minY: proxy.frame(in: .global).minY)])
                }
            )
            .onPreferenceChange(StickyHeaderPreferenceKey.self) { values in
                if let firstIndex = values.first, firstIndex.index == 0, firstIndex.minY > 100 {
                    topHeaderIndex = nil
                }
                let visibleHeaders = values.filter { $0.minY < 100 && $0.minY >= 0 } // 헤더가 상단에 도달한 경우
                if let topHeader = visibleHeaders.first {
                    topHeaderIndex = topHeader.index
                }
            }
        Divider()
            .padding(.vertical, 10)
            .foregroundStyle(Color.workoutListBorder)
    }
}

struct StickyHeaderData: Equatable {
    let index: Int
    let minY: CGFloat
}

struct StickyHeaderPreferenceKey: PreferenceKey {
    static var defaultValue: [StickyHeaderData] = []
    
    static func reduce(value: inout [StickyHeaderData], nextValue: () -> [StickyHeaderData]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    StickyHeaderView(index: 0,
                     title: "Hello",
                     topHeaderIndex: .constant(nil))
}
