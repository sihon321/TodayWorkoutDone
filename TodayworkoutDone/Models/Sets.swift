//
//  Sets.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import CoreData

struct Sets: Codable, Equatable, Identifiable {
    var id: UUID
    var prevWeight: Double
    var weight: Double
    var prevLab: Int
    var lab: Int
    var isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, prevWeight, weight, prevLab, lab, isChecked
    }
    
    init(id: UUID = UUID(),
         prevWeight: Double = .zero,
         weight: Double = .zero,
         prevLab: Int = .zero,
         lab: Int = .zero,
         isChecked: Bool = false) {
        self.id = id
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevLab = prevLab
        self.lab = lab
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        prevLab = try container.decode(Int.self, forKey: .prevLab)
        lab = try container.decode(Int.self, forKey: .lab)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
}
