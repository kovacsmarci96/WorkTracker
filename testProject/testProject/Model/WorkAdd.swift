//
//  WorkAdd.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 27..
//

import Foundation

class WorkAdd: Codable, Equatable{
    static func == (lhs: WorkAdd, rhs: WorkAdd) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String?
    var time: Double?
    var comment: String?
    var createdBy: String?
    var date: String?
    var taskId: String?
}
