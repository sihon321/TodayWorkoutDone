//
//  SwipeView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/8/25.
//

import SwiftUI

struct SwipeView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let onDelete: () -> Void

    @State private var offsetX: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0

    private let swipeLimit: CGFloat = -50
    private let threshold: CGFloat = -20
    private let imageWidth: CGFloat = 20
    private let imageHeight: CGFloat = 16

    var body: some View {
        ZStack(alignment: .trailing) {
            // 🟥 뒤에 있는 삭제 버튼
            HStack {
                Spacer()
                Button {
                    if offsetX != 0 {
                        withAnimation {
                            onDelete()
                        }
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.white)
                        .frame(width: imageWidth, height: imageHeight)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(Color.red)
                        .cornerRadius(5)
                }
            }

            // 🟦 실제 content 뷰
            content()
                .offset(x: max(swipeLimit, min(0, offsetX + gestureOffset))) // 스와이프 제한
                .highPriorityGesture(
                    DragGesture()
                        .updating($gestureOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { gesture in
                            let finalOffset = offsetX + gesture.translation.width
                            if finalOffset < threshold {
                                offsetX = swipeLimit // 열기
                            } else {
                                offsetX = 0 // 닫기
                            }
                        }
                )
                .onTapGesture {
                    withAnimation {
                        offsetX = 0
                    }
                }
        }
    }
}
