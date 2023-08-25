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
}
