//
//  UserWorkVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import UIKit

protocol UpdateWorkDelegate {
    func updateWork(_ work: Work, _ task: Task)
}

protocol UpdateSummaryDelegate {
    func updateSummaryWork(_ work: Work)
}

class UserWorkVC: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var workHourTF: UITextField!
    @IBOutlet weak var commentTF: UITextField!
    
    // MARK: - Variables
    
    var project = Project()
    var task = Task()
    var work = Work()
    var user = User()
    
    var projects = [Project]()
    var tasks = [Task]()
    
    var datePicker = UIDatePicker()
    var pickerView = UIPickerView()
    
    var delegate: UpdateWorkDelegate?
    var updateSummaryDelegate: UpdateSummaryDelegate?
    
    let hours = [1,2,3,4,5,6,7,8]
    
    // MARK: - View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTask()
        getProject()
        setupNavigationBar()
        setupLabels()
        createDatePicker()
    }
    
    func getTask() {
        task = tasks.first(where: {$0.id! == work.taskId!})!
    }
    
    func getProject() {
        project = projects.first(where: {$0.id! == task.projectId!})!
    }
    
    // MARK: - Setup functions
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Work"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    func setupLabels() {
        projectLabel.text = project.name
        taskLabel.text = task.name
        dateTF.text = work.createdDate
        workHourTF.text = String(work.time!)
        commentTF.text = work.comment
        
        pickerView.delegate = self
        workHourTF.inputView = pickerView
    }

}
