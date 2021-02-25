//
//  Challenge.swift
//  Groundbook
//
//  Created by admin on 02.01.2021.
//

import Foundation

struct Challenge: Identifiable {
    let id: UUID
    let documentID: String
    var name: String
    var description: String
    var grounds:[(id: UUID,ground: Ground,isVisited: Bool)]
}
