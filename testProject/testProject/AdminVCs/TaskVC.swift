//
//  TaskVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit
import Charts

class TaskVC: UIViewController, ChartViewDelegate {
    
    // MARK: - Variables
    var task = Task()
    var project = Project()
    var projects = [Project]()
    var works = [Work]()
    var users = [String]()
    var userWorks = [String : [Double]]()
    var taskHours = [String : Double]()
    var filteringOptions = ["All", "Today", "This week", "This month"]
    
    var user = User()
    
    var transparentView = UIView()
    var barChart = BarChartView()
    var pickerView = UIPickerView()
    
    var requiredColor = UIColor()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var viewForChart: UIView!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var chooser: UITextField!
    

    
    // MARK: - View functions

    override func viewDidLoad() {
        setupNavBar()
        setupUsersTableView()
        setupOther()
        setRedColor()
        setupChooser()
    
        let filter = chooser.text!
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllWork(self.project.id!, self.task.id!, semaphore)
            semaphore.wait()

            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.countHours(filter)
                self.usersTableView.reloadData()
                self.viewDidLayoutSubviews()
                self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
            }
        }
        
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        setupBarChart()
    }
        
    // MARK: - These functions sets up the view
    
    
    func setupNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = task.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    
    func setupUsersTableView() {
        usersTableView.delegate = self
        usersTableView.dataSource = self
    }
    
    func setupOther() {
        projectLabel.text = project.name
        taskNameTF.text = task.name
        descriptionTF.text = task.description
        barChart.delegate = self
    }
    
    func setupChooser() {
        chooser.tintColor = .clear
        chooser.text = "All"
        chooser.inputView = pickerView
        pickerView.delegate = self
    }
}
