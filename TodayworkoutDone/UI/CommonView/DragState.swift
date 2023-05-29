//
//  DragState.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/29.
//

import SwiftUI

enum CardPosition: CGFloat {
    case top = 100
    case middle = 200
    case bottom = 300
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
