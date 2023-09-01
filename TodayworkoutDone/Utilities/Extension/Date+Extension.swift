//
//  Date+Extension.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/19.
//

import Foundation

extension Date {
    func beginningOfDay() -> Date {
        let beginningOfDay = Calendar.current.startOfDay(for: self)
        return beginningOfDay
    }
    
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}
