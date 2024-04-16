//
//  WorkoutsType.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 3/27/24.
//

import Foundation

enum WorkoutsType: String, Codable {
    case machine, barbel, dumbbel, cable
    
    var kor: String {
        switch self {
        case .machine: "머신"
        case .barbel: "바벨"
        case .dumbbel: "덤벨"
        case .cable: "케이블"
        }
    }
}
