//
//  TabBarController.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import UIKit

class TabBarController: UITabBarController {
    
    var user = User()
    var loggedIn = Bool()
    var register = Bool()

    override func viewDidLoad() {
        
        loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        
        if !register {
            fetchUser()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user.role == "User" {
            self.tabBar.items?[4].isEnabled = false
        }
    }
    
    
    // Fetch the logged in user
    func fetchUser() {
        user.token = UserDefaults.standard.string(forKey: "token")
        user.name = UserDefaults.standard.string(forKey: "name")
        user.email = UserDefaults.standard.string(forKey: "email")
        user.userId = UserDefaults.standard.string(forKey: "id")
        user.role = UserDefaults.standard.string(forKey: "role")
    }

}
