//
//  ProfileVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit
import Charts

class ProfileVC: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var chooser: UITextField!
    @IBOutlet weak var viewForChart: UIView!
    
    
    //Variables
    var filteringOptions = ["All", "Today", "This week", "This month"]
    var user = User()
    var tabBar = TabBarController()
    var pickerView = UIPickerView()
    let barChart = BarChartView()
    
    var filteredWorks = [Work]()
    
    var taskWorks = [String : [Work]]()
    var taskHours = [String : Double]()
    var userWorks = [Work]()
    var userTasks = [Task]()
    
    var projects = [Project]()
    var tasks = [Task]()
    var works = [Work]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupPickerView()
        setupChooser()
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clear()
        tabBar.navigationItem.title = "Profile"
        let filter = chooser.text!
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllProjects(self.user.token!, semaphore)
            semaphore.wait()
            
            self.fetchTasks(semaphore, filter)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.countHours()
                self.viewDidLayoutSubviews()
                self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        setupBarChart()
    }
    
    func clear() {
        filteredWorks.removeAll()
        
        taskWorks.removeAll()
        taskHours.removeAll()
        userWorks.removeAll()
        userTasks.removeAll()
        
        projects.removeAll()
        tasks.removeAll()
        works.removeAll()
    }
    
    
    
    //Setup TabBar
    func setupTabBar() {
        user = tabBar.user
        tabBar = self.tabBarController as! TabBarController
        tabBar.navigationController?.navigationBar.prefersLargeTitles = true
        tabBar.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    //Setup PickerView
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    
    // MARK: - Setup labels
    func setupLabels() {
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
    
    
    //Setup Chooser
    func setupChooser() {
        chooser.tintColor = .clear
        chooser.text = "All"
        chooser.inputView = pickerView
    }
}
