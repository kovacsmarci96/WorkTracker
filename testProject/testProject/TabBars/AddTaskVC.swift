//
//  AddTaskVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class AddTaskVC: UIViewController {
    
    //Variables
    var projects = [Project]()
    var selectedProject = Project()
    var user = User()
    var tabBar = TabBarController()
    var requiredColor = UIColor()
    let transparentView = UIView()
    let tableView = UITableView()
    
    
    //IBOutlets
    @IBOutlet weak var btnSelectProject: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descrTF: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    
    //IBActions
    @IBAction func btnSelectProjectTapped(_ sender: Any) {
        addTransparentView(frames: btnSelectProject.frame)
    }
    @IBAction func btnAddTapped(_ sender: Any) {
        addTaskFunc()
    }
    
    
    //View actions
    override func viewDidLoad() {
        setupTabBar()
        user = tabBar.user
        setRedColor()
        setupTableView()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllProjects(user.token!)
        tabBar.navigationItem.title = "Add Task"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeTransparentView()
        clearForm()
    }
    
    
    // This function sets up the tabbar
    func setupTabBar() {
        tabBar = self.tabBarController as! TabBarController
        tabBar.navigationController?.navigationBar.prefersLargeTitles = true
        tabBar.navigationItem.largeTitleDisplayMode = .automatic
        tabBar.navigationItem.title = "Add Task"
        user = tabBar.user
    }
}
