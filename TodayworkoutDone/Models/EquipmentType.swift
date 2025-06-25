//
//  WorkoutsType.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 3/27/24.
//

import Foundation
import SwiftData

enum EquipmentType: String, Codable {
    case machine, barbel, dumbbel, cable
    case mat, reformer, cadillac, chair, barrel, springboard
    
    var kor: String {
        switch self {
        case .machine: "머신"
        case .barbel: "바벨"
        case .dumbbel: "덤벨"
        case .cable: "케이블"
            
        case .mat: "메트"
        case .reformer: "리포머"
        case .cadillac: "캐딜락"
        case .chair: "체어"
        case .barrel: "바렐"
        case .springboard: "스프링보드"
        }
    }
}
