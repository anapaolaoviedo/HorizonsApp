//
//  HorizonsAppApp.swift
//  HorizonsApp
//
//  Created by Ana Paola Oviedo on 8/16/25.
//

import SwiftUI

@main
struct HorizonsAppApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ProfileView()
            } else {
                LoginView()
            }
        }
    }
}
