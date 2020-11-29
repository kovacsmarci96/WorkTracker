//
//  AddWorkVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class AddWorkVC: UIViewController {
    
    //Variables
    let transparentView = UIView()
    var tableView = UITableView()
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    var tabBar = TabBarController()
    
    var projects = [Project]()
    var tasks = [Task]()
    var selectedProject = Project()
    var selectedTask = Task()
    var user = User()
    
    var size = CGFloat()
    var push = CGFloat()
    var pushBack = CGFloat()
    var requiredColor = UIColor()
    
    let dataSource = [String]()
    let hours = [1,2,3,4,5,6,7,8]
    
    var selectedButton = UIButton()
    
    
    
    
    //IBOutlets
    @IBOutlet weak var btnSelectProject: UIButton!
    @IBOutlet weak var btnSelectTask: UIButton!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var workHourTF: UITextField!
    @IBOutlet weak var commentTF: UITextField!
    
    
    //IBActions
    @IBAction func onClickSelectProject(_ sender: Any) {
        selectedButton = btnSelectProject
        addTransparentView(frames: btnSelectTask.frame)
    }
    @IBAction func onClickSelectTask(_ sender: Any) {
        selectedButton = btnSelectTask
        addTransparentView(frames: btnSelectTask.frame)
    }
    @IBAction func onClickAddWork(_ sender: Any) {
        if checkForm() {
            let work = WorkAdd()
            work.comment = commentTF.text
            work.date = dateTF.text
            work.time = Double(workHourTF.text!)
            work.createdBy = user.name
            
            
            clearForm()
            addWork(user.token!, work)
            makeAlert(title: "Success!", message: "Working hour has been saved.")
        }
    }
    
    //View actions
    override func viewDidLoad() {
        setupPickerView()
        setupDatePicker()
        setupRedColor()
        setupTableView()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUser()
        getAllProjects(user.token!)
        self.tabBarController?.navigationItem.title = "Add Work"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeTransparentView()
        projects.removeAll()
        tasks.removeAll()
        clearForm()
    }
    
    //  MARK: - Fetch user
    func fetchUser() {
        tabBar = self.tabBarController as! TabBarController
        user = tabBar.user
    }
    
    
    
    
    //Create TableView
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChooserCell.self, forCellReuseIdentifier: "ChooserCell")
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.layer.borderWidth = 3.0
        tableView.backgroundColor = requiredColor
    }
    
    
    //Create PickerView
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        workHourTF.inputView = pickerView
    }
    
    
    //Create DatePicker
    func setupDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let today = Date()
//        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -7, to: today)
        datePicker.maximumDate = today
        
        dateTF.inputAccessoryView = toolbar
        dateTF.inputView = datePicker
    }
}
