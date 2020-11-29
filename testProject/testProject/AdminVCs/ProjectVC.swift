//
//  ProjectVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit
import Charts

class ProjectVC: UIViewController, ChartViewDelegate {
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var viewForChart: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var createdByTF: UITextField!
    
    // MARK: - Variables
    
    var project = Project()
    var tasks = [Task]()
    var works = [Work]()
    var user = User()
    
    var barChart = BarChartView()
    
    // MARK: - View functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupTableView()
        setupOther()
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllTask(self.user.token!, self.project.id!, semaphore)
            semaphore.wait()
            
            self.fetchTaskHours(semaphore)
            semaphore.wait()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.tableView.reloadData()
                self.viewDidLayoutSubviews()
                self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        setupBarChart()
    }
    
    
    // MARK: - Setup functions
    func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = project.name
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupOther() {
        projectNameTF.isEnabled = false
        descriptionTF.isEnabled = false
        createdByTF.isEnabled = false
        
        barChart.delegate = self
        
        projectNameTF.text = project.name
        descriptionTF.text = project.description
        createdByTF.text = project.createdBy
    }
    
    // MARK: - Edit functions
    
    @objc func editTapped() {
        editing()
    }
    
    func editing() {
        projectNameTF.isEnabled = true
        descriptionTF.isEnabled = true
        projectNameTF.becomeFirstResponder()
        projectNameTF.borderStyle = .roundedRect
        descriptionTF.borderStyle = .roundedRect
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    }
    
    @objc func doneEditing() {
        projectNameTF.isEnabled = false
        descriptionTF.isEnabled = false
        projectNameTF.borderStyle = .none
        descriptionTF.borderStyle = .none
        createdByTF.borderStyle = .none
        updateProject()
        self.navigationItem.title = projectNameTF.text
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
}
