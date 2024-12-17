//
//  EthFussApp.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import SwiftUI
import SwiftData
import EthCore

@main
struct EthFussApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                ExploreMainScreenView(viewModel: .init())
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                EthTopologhyView()
                    .tabItem {
                        Label("View", systemImage: "photo")
                    }
            }
            
        }
        .modelContainer(sharedModelContainer)
    }
}
