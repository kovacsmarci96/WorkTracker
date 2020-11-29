//
//  Project.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation

class Project: Codable, Equatable {
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var name: String?
    var description : String?
    var createdBy: String?
    var createdTime: String?
}
