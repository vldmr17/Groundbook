//
//  User.swift
//  Groundbook
//
//  Created by admin on 15.11.2020.
//

class User {
    var uid: String
    var displayName: String?
    var email: String?

    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }

}
