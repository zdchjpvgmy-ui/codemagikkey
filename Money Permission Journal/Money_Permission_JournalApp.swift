//
//  Money_Permission_JournalApp.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

@main
struct Money_Permission_JournalApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showSplash = true
    @State private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView(isComplete: Binding(
                        get: { !showSplash },
                        set: { newValue in
                            if newValue {
                                showSplash = false
                            }
                        }
                    ))
                    .preferredColorScheme(themeManager.colorScheme)
                } else {
                    MainTabView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environment(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                }
            }
        }
    }
}
