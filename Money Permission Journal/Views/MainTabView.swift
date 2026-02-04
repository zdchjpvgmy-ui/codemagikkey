//
//  MainTabView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "calendar")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "tag.fill")
                }
            
            MoreTabView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .accentColor(.appSkyBlue)
    }
}

struct MoreTabView: View {
    @State private var selectedView: MoreViewOption = .reflection
    
    enum MoreViewOption {
        case reflection
        case gallery
        case export
        case settings
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ReflectionView()) {
                        Label("Reflection", systemImage: "heart.text.square.fill")
                    }
                    
                    NavigationLink(destination: GalleryView()) {
                        Label("Gallery", systemImage: "sparkles")
                    }
                    
                    NavigationLink(destination: ExportView()) {
                        Label("Export & Backup", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabView()
}
