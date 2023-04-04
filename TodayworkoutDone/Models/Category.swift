//
//  Category.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import CoreData

@objc(Category)
class Category: NSManagedObject, Codable {
    @NSManaged var kor: String?
    @NSManaged var en: String?
    
    enum CodingKeys: String, CodingKey {
        case kor, en
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Category",
                                                    in: managedObjectContext) else {
            fatalError("Failed to decode Category")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kor = try container.decode(String.self, forKey: .kor)
        en = try container.decode(String.self, forKey: .en)
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
