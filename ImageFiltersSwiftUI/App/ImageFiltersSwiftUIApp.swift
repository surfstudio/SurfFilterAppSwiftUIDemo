//
//  ImageFiltersSwiftUIApp.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 22.10.2020.
//

import SwiftUI

@main
struct ImageFiltersSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FilterPreviewStore().state)
        }
    }
}
