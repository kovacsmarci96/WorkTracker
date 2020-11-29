//
//  UserProjectVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import UIKit
import Charts

protocol RefreshProjectDelegate {
    func refreshProjects(_ work: Work)
}

class UserProjectVC: UIViewController, ChartViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewForChart: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    // MARK: - Variables
    
    var project = Project()
    var userTasks = [Task]()
    var works = [Work]()
    var taskWorks = [String : [Work]]()
    var projectWorks = [String : [Work]]()
    
    var user = User()
    
    var projectTasks = [Task]()
    var userProjects = [Project]()
    
    var delegate: RefreshProjectDelegate?
    
    var taskHours = [String : Double]()
    var projectTaskHours = [String : Double]()
    var projectHours = [String : [Double]]()
    
    var barChart = BarChartView()
    
    // MARK: - View functions

    override func viewDidLoad() {
        setupNavigationBar()
        setupDelegates()
        setupLabels()
        count()
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    override func viewDidLayoutSubviews() {
        setupBarChart(taskHours)
    }
    
    // MARK: - These functions sets up the view
    
    func setupNavigationBar() {
        self.navigationItem.title = project.name!
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func setupDelegates() {
        barChart.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupLabels() {
        descriptionLabel.text = project.description!
        userLabel.text = project.createdBy!
        projectLabel.text = project.name!
    }


}
