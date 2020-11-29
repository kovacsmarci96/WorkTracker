//
//  SummaryVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class SummaryVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var chooser: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cView: UICollectionView!
    
    
    //MARK: - Variables
    var user = User()
    
    var projects = [Project]()
    var tasks = [Task]()
    var works = [Work]()
    
    var userProjects = [Project]()
    var userTasks = [Task]()
    var userWorks = [Work]()
    
    var filteredWorks = [Work]()
    
    var projectWorks = [String : [Work]]()
    var taskWorks = [String : [Work]]()
    
    var projectHours = [String : Double]()
    var taskHours = [String : Double]()
    
    var filteringOptions = ["All", "Today", "This week", "This month"]
    var states = ["Project", "Task", "Work"]
    
    var tabBar = TabBarController()
    var pickerView = UIPickerView()
    var cell = PieChartCell()
    
    var showProjects = true
    var showTasks = false
    var showWorks = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupChooser()
        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        clearRepo()
        tabBar.navigationItem.title = "Summary"
        let filter = chooser.text!
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllProjects(self.user.token!, semaphore)
            semaphore.wait()
            
            self.fetchTasks(semaphore, filter)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.count()
                self.cView.reloadData()
                self.tableView.reloadData()
                self.cell.animate()
            }
        }
    }
    
    func clearRepo() {
        projects.removeAll()
        tasks.removeAll()
        works.removeAll()
        userProjects.removeAll()
        userTasks.removeAll()
        userWorks.removeAll()
        projectWorks.removeAll()
        taskWorks.removeAll()
        projectHours.removeAll()
        taskHours.removeAll()
    }
    
    func setupCollectionView() {
        cView.delegate = self
        cView.dataSource = self
        cView.isPagingEnabled = true
        cView.register(PieChartCell.self, forCellWithReuseIdentifier: "chartCell")
        cView.automaticallyAdjustsScrollIndicatorInsets = false
    }

    
    func setupTabBar() {
        tabBar = self.tabBarController as! TabBarController
        tabBar.navigationController?.navigationBar.prefersLargeTitles = true
        tabBar.navigationItem.largeTitleDisplayMode = .automatic
        
        let button = UIBarButtonItem(title: "Logout", style: .plain, target: self,action: #selector(logOut))
        tabBar.navigationItem.leftBarButtonItem = button
        user = tabBar.user
    }
    
    func setupChooser() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        chooser.text = "All"
        chooser.tintColor = .clear
        chooser.inputView = pickerView
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}
