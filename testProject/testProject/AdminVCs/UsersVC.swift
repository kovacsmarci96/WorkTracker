//
//  UsersVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class UsersVC: UITableViewController {
    
    // MARK: - Variables
    
    var fetchedUsers = [User]()
    var adminUsers = [User]()
    var users = [User]()
    var user = User()
    
    
    // MARK: - View functions
    
    override func viewDidLoad() {
        setupNavigationBar()
        super.viewDidLoad()
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllUser(semaphore)
            semaphore.wait()
            DispatchQueue.main.async {
                self.filterUsers()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Sets up the navigation bar
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Users"
    }

    // MARK: - Table view functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Admins"
        } else {
            return "Users"
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return adminUsers.count
        } else {
            return users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UsersCell
        if indexPath.section == 0 {
            cell.nameLabel.text = adminUsers[indexPath.row].name
        } else {
            cell.nameLabel.text = users[indexPath.row].name
        }
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 30.0
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "userVC") as! UserVC
        if indexPath.section == 0 {
            vc.user = adminUsers[indexPath.row]
            vc.loggedInUser = self.user
        } else {
            vc.user = users[indexPath.row]
            vc.loggedInUser = self.user
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
