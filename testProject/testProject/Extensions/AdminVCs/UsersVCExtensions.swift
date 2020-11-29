//
//  UsersVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import Foundation
import UIKit

extension UsersVC {
    func filterUsers() {
        for user in fetchedUsers {
            if user.role == "Admin" {
                if !(adminUsers.contains(user)) {
                    adminUsers.append(user)
                }
            } else {
                users.append(user)
            }
        }
        self.adminUsers.sort { $0.name!.lowercased() < $1.name!.lowercased() }
        self.users.sort { $0.name!.lowercased() < $1.name!.lowercased() }
    }
    
    func getAllUser(_ semaphore: DispatchSemaphore) {
        let userRequest = UserRequest.init(endpoint: "")
        
        userRequest.getAllUser(user.token!,completion: {result in
            switch result{
            case .success(let nowFetched):
                self.fetchedUsers = nowFetched
                print("Users fetched \(self.fetchedUsers.count)")
                self.fetchedUsers.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                semaphore.signal()
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
}
