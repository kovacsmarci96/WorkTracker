//
//  UserTaskVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import UIKit
import Charts

protocol UpdateTaskDelegate {
    func updateTask(_ task: Task,_ work: Work)
}

protocol DeleteWorkDelegate {
    func deleteWork(_ work: Work,_ taskWorkCount: Int,_ task: Task)
}

protocol UpdateSummaryTaskDelegate {
    func updateSummaryTask(_ work: Work)
}

class UserTaskVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewForChart: UIView!
    
    // MARK: - Variables
    
    var task = Task()
    var works = [Work]()
    var taskWorks = [Work]()
    var projects = [Project]()
    var project = Project()
    var tasks = [Task]()
    
    var updateTaskDelegate: UpdateTaskDelegate?
    var deleteWorkDelegate: DeleteWorkDelegate?
    var updateSummaryDelegate: UpdateSummaryTaskDelegate?
    
    var user = User()
    
    var barChart = BarChartView()
    
    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLabels()
        setupTableView()
        fetchTaskWorks()
    }
    
    override func viewDidLayoutSubviews() {
        setupBarChart()
    }
    
    // MARK: - This function gets the project for the task
    
    func getProject() {
        project = projects.first(where: {$0.id! == task.projectId!})!
    }
    
    // MARK: - Setup functions
    
    func setupNavigationBar() {
        self.navigationItem.title = task.name!
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func setupLabels() {
        getProject()
        projectLabel.text = project.name!
        descriptionLabel.text = task.description!
        userLabel.text = task.createdBy!
        taskLabel.text = task.name!
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}
