//
//  Work.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation


class Work: Codable, Equatable{
    static func == (lhs: Work, rhs: Work) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String?
    var time: Double?
    var comment: String?
    var createdBy: String?
    var createdDate: String?
    var taskId: String?
}
