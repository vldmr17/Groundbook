//
//  Ground.swift
//  Groundbook
//
//  Created by admin on 26.11.2020.
//

import SwiftUI

struct Ground: Identifiable {
    let id: UUID
    let documentID: String
    var name: String
    var capacity: Int
    var isDemolished: Bool
    var opened: Int
    var country: Country
    var photoURL: URL
    var latitude: Double
    var longitude: Double
    var tenants:[Team]
}
