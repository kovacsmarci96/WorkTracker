//
//  AdminVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class AdminVC: UITableViewController {

    
    // MARK: - Variables
    
    var tabBar = TabBarController()
    var user = User()

    
    // MARK: - View functions
    
    override func viewDidLoad() {
        setupTabBar()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Admin"
    }
    
    
    // MARK: - Tab bar setup
    
    func setupTabBar() {
        self.tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.navigationItem.largeTitleDisplayMode = .automatic
        tabBar = self.tabBarController as! TabBarController
        user = tabBar.user
    }

    // MARK: - Table view data functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Manage Users"
        }
        if section == 1 {
            return "Manage Projects"
        }
        if section == 2 {
            return "Manage Tasks"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell")
        if(indexPath.section == 0) {
            cell?.textLabel?.text = "Users"
        }
        if(indexPath.section == 1) {
            cell?.textLabel?.text = "Projects"
        }
        if(indexPath.section == 2) {
            cell?.textLabel?.text = "Tasks"
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            let vc = storyboard?.instantiateViewController(identifier: "usersVC") as! UsersVC
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if(indexPath.section == 1) {
            let vc = storyboard?.instantiateViewController(identifier: "projectsVC") as! ProjectsVC
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if(indexPath.section == 2) {
            let vc = storyboard?.instantiateViewController(identifier: "tasksVC") as! TasksVC
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
