//
//  GroundbookApp.swift
//  Groundbook
//
//  Created by admin on 14.11.2020.
//

import SwiftUI
import Firebase

@main
struct GroundbookApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(DBService()).environmentObject(SessionStore())
        }
    }
}
