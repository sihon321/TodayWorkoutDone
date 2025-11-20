//
//  SlideOverCardView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/29.
//

import SwiftUI

struct SlideOverCardView<Content: View>: View {
    // 1. @GestureState를 삭제하고 일반 @State로 변경
    // @GestureState private var dragState = DragState.inactive
    @State private var dragTranslation: CGSize = .zero
    
    @Binding var hideTabValue: CGFloat
    @State var offset: CGFloat = 0
    @State private var position: CGFloat = 10
    
    var abovePosition: CGFloat = 10
    var content: () -> Content
    
    var body: some View {
        let drag = DragGesture()
            // 2. .updating 대신 .onChanged 사용
            .onChanged { value in
                let topLimit = self.abovePosition
                let proposedY = self.position + value.translation.height
                
                // Clamping 로직 (위로 더 못 올라가게)
                let effectiveY = max(proposedY, topLimit)
                
                // 현재 위치에서 effectiveY가 되기 위한 translation 값 계산
                self.dragTranslation = CGSize(width: value.translation.width, height: effectiveY - self.position)
            }
            .onEnded { value in
                // 3. onEnded 로직 수행
                onDragEnded(drag: value)
            }
        
        return Group {
            // ... (기존 디자인 코드 동일) ...
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.5)
                .frame(width: 40, height: UIScreen.main.bounds.size.height - 50)
                .foregroundStyle(Color.secondary)
            
            self.content()
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -1 * proxy.frame(in: .global).origin.y
                        )
                    }
                )
                .transaction { transaction in
                    // 드래그 중이라면 content 내부에서 일어나는 모든 변화의 애니메이션을 꺼버림
                    if self.dragTranslation != .zero {
                        transaction.disablesAnimations = true
                    }
                }
                .onPreferenceChange(ViewOffsetKey.self, perform: { value in
                    // ... (기존 preference 로직 동일) ...
                    let slideBottomStopHeight: CGFloat = 284.0
                    let topSafeArea: CGFloat = 47.5
                    let bottomSafeArea: CGFloat = 10.0
                    let frameHeight = UIScreen.main.bounds.size.height - topSafeArea - bottomSafeArea
                    let slideBottomeStopY = (frameHeight - slideBottomStopHeight + topSafeArea - bottomSafeArea)
                    let tabBarHeight: CGFloat = 78.0
                    
                    if value < 0 {
                        hideTabValue = slideBottomeStopY + value > 0.0 ? slideBottomeStopY + value : 0.0
                    } else {
                        hideTabValue = (topSafeArea + tabBarHeight + bottomSafeArea) - value
                    }
                })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.slideCardBackground) // Color 정의 필요
        .cornerRadius(40.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        
        // 4. offset에 변경된 State 적용
        .offset(y: self.position + self.dragTranslation.height)
        
        // 5. gesture 적용 (animation 수정자 없음)
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        
        // 실제 뷰가 이동한 위치 (Clamping된 dragTranslation 사용)
        // 중요: drag.translation 대신 현재 화면에 보이는 dragTranslation을 기준점으로 삼아야 튐 현상이 없습니다.
        let currentDragHeight = self.dragTranslation.height
        let cardTopEdgeLocation = self.position + currentDragHeight
        
        let positionAbove: CGFloat = abovePosition
        let positionBelow: CGFloat = UIScreen.main.bounds.size.height - 200
        let closestPosition: CGFloat
        
        if (cardTopEdgeLocation - positionAbove) < (positionBelow - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        // 6. 애니메이션과 함께 위치 이동 및 드래그 값 초기화
        withAnimation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)) {
            if verticalDirection > 0 {
                self.position = positionBelow
            } else if verticalDirection < 0 {
                self.position = positionAbove
            } else {
                self.position = closestPosition
            }
            
            // ★ 핵심: position이 이동했으므로 dragTranslation은 0으로 리셋
            self.dragTranslation = .zero
        }
    }
}
