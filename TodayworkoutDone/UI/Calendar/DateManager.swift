//
//  DateManager.swift
//  TodayworkoutDone
//
//  Created by oceano on 1/15/25.
//

import Foundation

class DateManager {
    
    // MARK: - Properties
    private var calendar: Calendar
    private var formatter: DateFormatter
    
    // MARK: - Initializer
    init() {
        self.calendar = Calendar.current
        self.calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!  // 한국 시간대 적용
        
        self.formatter = DateFormatter()
        self.formatter.locale = Locale(identifier: "ko_KR")  // 한국어 요일 출력
    }
    
    // MARK: - 이번 주 월요일 날짜 반환
    func getMondayOfCurrentWeek(from date: Date = Date()) -> Date? {
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = (weekday == 1) ? 6 : weekday - 2
        
        if let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) {
            return calendar.startOfDay(for: monday)
        }
        
        return nil
    }
    
    // MARK: - 주간 날짜 딕셔너리 생성 (기본값 0.0)
    func createWeeklyDateDictionary(from startDate: Date) -> [Date: Double] {
        var dateDictionary: [Date: Double] = [:]
        
        for i in 0...6 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let startOfDay = calendar.startOfDay(for: date)
                dateDictionary[startOfDay] = 0.0
            }
        }
        
        return dateDictionary
    }
    
    // MARK: - 주간 날짜 배열 생성
    func createWeekDates(from startDate: Date) -> [Date] {
        var dates: [Date] = []
        
        for i in 0...6 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let startOfDay = calendar.startOfDay(for: date)
                dates.append(startOfDay)
            }
        }
        
        return dates
    }
    
    // MARK: - 요일 문자열 반환 ("월", "화", "수" 등)
    func getWeekdayString(from date: Date) -> String {
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // MARK: - 날짜를 문자열로 변환 ("yyyy-MM-dd")
    func formatDateToString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
