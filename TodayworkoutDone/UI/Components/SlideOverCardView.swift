//
//  SlideOverCardView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/29.
//

import SwiftUI

struct SlideOverCardView<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @Binding var hideTabValue: CGFloat
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    
    @State private var position: CGFloat = 10
    var abovePosition: CGFloat = 10
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                if self.position > abovePosition {
                    state = .dragging(translation: drag.translation)
                } else if self.position == abovePosition
                            && drag.predictedEndLocation.y - drag.location.y > 0 {
                    state = .dragging(translation: drag.translation)
                }
            }
            .onEnded(onDragEnded)
        
        return Group {
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.5)
                .frame(width: 40, height: UIScreen.main.bounds.size.height - 50)
                .foregroundColor(Color.secondary)
            self.content()
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -1 * proxy.frame(in: .global).origin.y
                        )
                    }
                )
                .onPreferenceChange(ViewOffsetKey.self, perform: { value in
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
        .background(Color.slideCardBackground)
        .cornerRadius(40.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: self.position + self.dragState.translation.height)
        .transition(.move(edge: .top))
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0,
                                                                          damping: 30.0,
                                                                          initialVelocity: 10.0),
                   value: 1.0)
        .gesture(drag)
        .overlay(
            GeometryReader { proxy -> Color in
                let minY = position
                let durationOffset: CGFloat = 25
                DispatchQueue.main.async {
                    if self.dragState.translation.height < 0 && minY > (lastOffset + durationOffset) {
                        lastOffset = -self.dragState.translation.height
                    }
                    
                    if 0 < self.dragState.translation.height && -minY < (lastOffset - durationOffset) {
                        lastOffset = -self.dragState.translation.height
                    }
                }
                return Color.clear
            }
        )
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position + drag.translation.height
        let positionAbove: CGFloat = abovePosition
        let positionBelow: CGFloat = UIScreen.main.bounds.size.height / 1.5
        let closestPosition: CGFloat

        if (cardTopEdgeLocation - positionAbove) < (positionBelow - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

