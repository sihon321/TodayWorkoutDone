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
        return dateFormatter.date(from: dateString)!
    }
    
    static var midnight: Date {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let dateString = dateFormatter.string(from: currentDate)
        
        return dateFormatter.date(from: dateString)!
    }
    
    func formatToKoreanStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일, EEEE, a h:mm"
        return dateFormatter.string(from: self)
    }
    
    var dateForDeviceRegion: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let dateString = dateFormatter.string(from: self)
        return dateFormatter.date(from: dateString)!
    }
}

extension Array where Element == Date {
    
    func calculateAverageSecondsBetweenDates() -> Double {
        guard self.count > 1 else {
            return 0 // 날짜가 1개 이하면 간격을 계산할 수 없음
        }
        
        let sortedDates = self.sorted()
        var totalSeconds = 0.0
        
        for i in 1..<sortedDates.count {
            let interval = sortedDates[i].timeIntervalSince(sortedDates[i-1])
            totalSeconds += interval
        }
        
        return totalSeconds / Double(sortedDates.count - 1)
    }

}

