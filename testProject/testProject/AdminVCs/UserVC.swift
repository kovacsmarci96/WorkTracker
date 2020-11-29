//
//  UserVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit
import Charts

class UserVC: UIViewController, ChartViewDelegate {
    
    // MARK: - Variables
    var projects = [Project]()
    var tasks = [Task]()
    var works = [Work]()
    var filteredWorks = [Work]()
    
    var taskWorks = [String : [Work]]()
    var taskHours = [String : Double]()
    var userWorks = [Work]()
    var userTasks = [Task]()
    
    var user = User()
    var loggedInUser = User()
    var filteringOptions = ["All", "Today", "This week", "This month"]
    
    var barChart = BarChartView()
    @IBOutlet weak var viewForChart: UIView!
    var pickerView = UIPickerView()
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var chooser: UITextField!
    
    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLabels()
        setupDelegates()
        setupChooser()
        
        let filter = chooser.text!
        
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllProjects(self.loggedInUser.token!, semaphore)
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
    
    // MARK: - Setup functions
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = user.name
    }
    
    func setupLabels() {
        nameLabel.text = user.name
        roleLabel.text = user.role
    }
    
    func setupDelegates() {
        pickerView.delegate = self
        barChart.delegate = self
    }
    
    func setupChooser() {
        chooser.tintColor = .clear
        chooser.text = "All"
        chooser.inputView = pickerView
    }

}
