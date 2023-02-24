//
//  SlideOverCardView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/29.
//

import SwiftUI

struct SlideOverCardView<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State private var position: CGFloat = 100
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                if self.position > UIScreen.main.bounds.size.height / 10 {
                    state = .dragging(translation: drag.translation)
                } else if self.position == UIScreen.main.bounds.size.height / 10
                            && drag.predictedEndLocation.y - drag.location.y > 0 {
                    state = .dragging(translation: drag.translation)
                }
            }
            .onEnded(onDragEnded)
        
        return Group {
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.5)
                .frame(width: 40, height: CGFloat(5.0))
                .foregroundColor(Color.secondary)
                .padding(5)
            self.content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("slideCardBackground"))
        .cornerRadius(40.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: self.position + self.dragState.translation.height)
        .transition(.move(edge: .top))
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0,
                                                                          damping: 30.0,
                                                                          initialVelocity: 10.0),
                   value: 1.0)
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position + drag.translation.height
        let positionAbove: CGFloat
        let positionBelow: CGFloat
        let closestPosition: CGFloat
        
        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = UIScreen.main.bounds.size.height / 10
            positionBelow = UIScreen.main.bounds.size.height / 3
        } else {
            positionAbove = UIScreen.main.bounds.size.height / 2
            positionBelow = UIScreen.main.bounds.size.height / 1.3
        }
        
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

