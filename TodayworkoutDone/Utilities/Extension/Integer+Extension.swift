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
}
