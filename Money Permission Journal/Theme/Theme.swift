//
//  Theme.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light
    case dark
    case system
}

@Observable
class ThemeManager {
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.selectedTheme)
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedTheme) ?? "system"
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
    
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
