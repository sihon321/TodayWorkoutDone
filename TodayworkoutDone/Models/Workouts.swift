//
//  Workouts.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation

class Excercise: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
    }

    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

class Workouts: Excercise {
    var category: String
    var target: String
    
    enum CodingKeys: String, CodingKey {
        case name, category, target
    }
    
    init(name: String, category: String, target: String) {
        self.category = category
        self.target = target

        super.init(name: name)
    }
    
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Workouts.self, from: data)
        self.init(name: me.name, category: me.category, target: me.target)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        category = try container.decode(String.self, forKey: .category)
        target = try container.decode(String.self, forKey: .target)
        
        try super.init(from: decoder)
    }
}
