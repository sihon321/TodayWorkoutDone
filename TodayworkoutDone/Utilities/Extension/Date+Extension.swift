//
//  Date+Extension.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/19.
//

import Foundation

extension Date {
    var year: Int? {
        let dateComponents = Calendar.current.dateComponents([.year], from: self)
        return dateComponents.year
    }
    var month: Int? {
        let dateComponents = Calendar.current.dateComponents([.month], from: self)
        return dateComponents.month
    }
    var day: Int? {
        let dateComponents = Calendar.current.dateComponents([.day], from: self)
        return dateComponents.day
    }
}
