//
//  Sets.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import CoreData

struct Sets: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    
    var prevWeight: Double
    var weight: Double
    var prevLab: Int
    var lab: Int
    var isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case prevWeight, weight, prevLab, lab, isChecked
    }
    
    init(prevWeight: Double = .zero,
         weight: Double = .zero,
         prevLab: Int = .zero,
         lab: Int = .zero,
         isChecked: Bool = false) {
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevLab = prevLab
        self.lab = lab
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        prevLab = try container.decode(Int.self, forKey: .prevLab)
        lab = try container.decode(Int.self, forKey: .lab)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
}
