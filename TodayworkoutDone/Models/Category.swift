//
//  Category.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import CoreData

struct Category: Codable, Identifiable {
    var id: UUID = UUID()
    var kor: String?
    var en: String?
    
    enum CodingKeys: String, CodingKey {
        case kor, en
    }
    
    init(kor: String, en: String) {
        self.kor = kor
        self.en = en
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kor, forKey: .kor)
        try container.encode(en, forKey: .en)
    }
}

typealias Categories = [Category]

extension Categories {
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
