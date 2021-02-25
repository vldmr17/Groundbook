//
//  Match.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import Foundation

struct Match: Identifiable {
    let id: UUID
    let documentID: String
    var home: Team?
    var away: Team?
    var homeScore: Int
    var awayScore: Int
    var ground: Ground?
    var tournament: Tournament?
    var date: Date
}
