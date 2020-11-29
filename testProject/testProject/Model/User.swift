//
//  LoggedInUser.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import Foundation


class User: Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var token: String?
    var userId: String?
    var name: String?
    var email: String?
    var role: String?
}
