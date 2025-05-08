//
//  HorizontalFilterView.swift
//  TodayworkoutDone
//
//  Created by oceano on 2/26/25.
//

import SwiftUI

struct HorizontalFilterView: View {
    var filters: [String]
    @Binding var selectedFilters: Set<String>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    FilterButton(title: filter, isSelected: selectedFilters.contains(filter)) {
                        if selectedFilters.contains(filter) {
                            selectedFilters.remove(filter)
                        } else {
                            selectedFilters.insert(filter)
                        }
                    }
                }
                .offset(x: 15)
            }
            .padding(.vertical, 1)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(isSelected ? Color(.primary).opacity(0.7) : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // Squircle 효과
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(isSelected ? Color(.primary) : Color.gray.opacity(0.5), lineWidth: 1)
            )
            .onTapGesture {
                action()
            }
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
