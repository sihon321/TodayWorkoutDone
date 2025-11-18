//
//  Array+Extension.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/25/25.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
