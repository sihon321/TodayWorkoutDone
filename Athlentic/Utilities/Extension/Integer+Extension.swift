//
//  Integer+Extension.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 10/12/23.
//

import Foundation

extension Int {
    var secondToHMS: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        var hms = ""
        
        if h > 0 {
            hms += "\(h):"
        }
        
        if m < 10 {
            hms += "0\(m):"
        } else if m >= 10 {
            hms += "\(m):"
        }
        
        if s < 10 {
            hms += "0\(s)"
        } else if s >= 10 {
            hms += "\(s)"
        }
        return hms
    }
    
    func convertSecondsToHMS() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let remainingSeconds = self % 60
        
        var result: String = ""
        if hours > 0 {
            result += "\(hours)시간 "
        }
        
        if minutes > 0 {
            result += "\(minutes)분 "
        }
        
        result += "\(remainingSeconds)초"
        
        return result
    }
    
    func formattedTime() -> String {
        let totalSeconds = self
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

