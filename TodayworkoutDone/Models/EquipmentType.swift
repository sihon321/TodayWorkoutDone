//
//  WorkoutsType.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 3/27/24.
//

import Foundation
import SwiftData

enum EquipmentType: String, Codable {
    case machine, barbell, dumbbell, cable, bar, body
    case mat, reformer, cadillac, chair, barrel, springboard
    
    case none
    
    var kor: String {
        switch self {
        case .machine: "머신"
        case .barbell: "바벨"
        case .dumbbell: "덤벨"
        case .cable: "케이블"
        case .bar: "바"
        case .body: "맨몸"
            
        case .mat: "메트"
        case .reformer: "리포머"
        case .cadillac: "캐딜락"
        case .chair: "체어"
        case .barrel: "바렐"
        case .springboard: "스프링보드"
            
        case .none: ""
        }
    }
    
    init?(kor: String) {
        switch kor {
        case "머신": self = .machine
        case "바벨": self = .barbell
        case "덤벨": self = .dumbbell
        case "케이블": self = .cable
        case "바": self = .bar
        case "맨몸": self = .body
            
        case "매트": self = .mat
        case "리포머": self = .reformer
        case "캐딜락": self = .cadillac
        case "체어": self = .chair
        case "바렐": self = .barrel
        case "스프링보드": self = .springboard
            
        default: return nil
        }
    }
}
