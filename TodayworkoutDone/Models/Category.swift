//
//  Category.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import CoreData

struct Category: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension Category: Identifiable {
    var id: String { return name }
}

typealias Categories = [Category]

extension Categories {
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
