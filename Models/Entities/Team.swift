//
//  Team.swift
//  Groundbook
//
//  Created by admin on 01.12.2020.
//

import Foundation

struct Team: Identifiable {
    let id: UUID
    let documentID: String
    var name: String
    var logoURL: URL
    let venue: String
    var country: Country
}
