//
//  String+Extension.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/20/25.
//

import Foundation

extension String {
    func timeStringToSeconds() -> Int {
        let components = self.split(separator: ":")
        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]) else {
            return 0
        }
        return minutes * 60 + seconds
    }
    
    func formattedTime() -> String {
        guard !self.isEmpty else {
            return ""
        }
        let digitsOnly = self.filter { $0.isNumber }
        let number = Int(digitsOnly) ?? 0
        var minutes = number / 100
        let remainder = (number % 100)
        minutes += remainder / 60
        let seconds = remainder % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
