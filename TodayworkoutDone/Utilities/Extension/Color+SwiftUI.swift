//
//  Color+SwiftUI.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/11.
//

import SwiftUI

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
          .sRGB,
          red: Double((hex >> 16) & 0xFF) / 255,
          green: Double((hex >> 8) & 0xFF) / 255,
          blue: Double(hex & 0xFF) / 255,
          opacity: alpha
        )
      }
}

extension Color {
    static let personal = Color("personal")
    static let gray88 = Color("gray_88")
    static let slideCardBackground = Color("slide_card_background")
    static let background = Color("background")
    static let tabBarBackground = Color("tab_bar_background")
    static let tabBarBorder = Color("tab_bar_border")
    static let todBlack = Color("tod_black")
    static let contentBackground = Color("content_background")
    static let todWhite = Color("tod_white")
}
