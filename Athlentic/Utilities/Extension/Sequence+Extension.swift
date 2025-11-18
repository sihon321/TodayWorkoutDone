//
//  Sequence+Extension.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 10/14/23.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
