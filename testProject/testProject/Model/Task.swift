//
//  Task.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation

class Task: Codable, Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var name: String?
    var description : String?
    var createdDate: String?
    var createdBy: String?
    var projectId: String?
    var taskHour: Double?
}
