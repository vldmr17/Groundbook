//
//  Tournament.swift
//  Groundbook
//
//  Created by admin on 01.12.2020.
//

import Foundation

struct Tournament: Identifiable {
    let id: UUID
    let documentID: String
    var name: String
    var logoURL: URL
    var country: Country
}
