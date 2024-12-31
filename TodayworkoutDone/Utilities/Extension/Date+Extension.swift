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
    
    static var currentDateForDeviceRegion: Date {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let dateString = dateFormatter.string(from: currentDate)
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: dateString)!
    }
    
    static var midnight: Date {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let dateString = dateFormatter.string(from: currentDate)
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.date(from: dateString)!
    }
}
