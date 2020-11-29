//
//  AddTaskVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

extension AddTaskVC: UITableViewDelegate {
    
}

extension AddTaskVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooserCell") as! ChooserCell
        cell.textLabel?.text = projects[indexPath.row].name
        cell.backgroundColor = requiredColor
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnSelectProject.setTitle(projects[indexPath.row].name, for: .normal)
        selectedProject = projects[indexPath.row]
        removeTransparentView()
    }
}

extension AddTaskVC {
    
    // This function sets up the tableview
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChooserCell.self, forCellReuseIdentifier: "ChooserCell")
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.layer.borderWidth = 3.0
        tableView.backgroundColor = requiredColor
    }
    
    
    //These functions make the tableview and the transparentview
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x+16, y: frames.origin.y + frames.height+180, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 25
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        tapgesture.cancelsTouchesInView = false
        tapgesture.numberOfTapsRequired = 1
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { [self] in
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x + 16, y: frames.origin.y + frames.height+180, width: frames.width, height: CGFloat(projects.count * 43))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = btnSelectProject.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x + 16, y: frames.origin.y + frames.height + 180, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    
    //This function checks the form
    func checkForm() -> Bool {
        if btnSelectProject.currentTitle == "Select Project" {
            makeAlert(title: "Error", message: "Please select a project.")
            return false
        }
        if descrTF.text == "" {
            makeAlert(title: "Error", message: "Please add a description.")
            return false
        }
        if nameTF.text == "" {
            makeAlert(title: "Error", message: "Please add a task name.")
            return false
        }
        return true
    }
    
    
    
    //This function sets the required color
    func setRedColor() {
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        let cgRequiredColor = CGColor(colorSpace: sRGB, components: [0.809147, 0, 0, 1])!
        requiredColor = UIColor(cgColor: cgRequiredColor)
    }
    
    
    //This function clears the form
    func clearForm() {
        nameTF.text = ""
        descrTF.text = ""
        btnSelectProject.setTitle("Select Project", for: .normal)
        nameTF.resignFirstResponder()
        descrTF.resignFirstResponder()
    }
    
    //Date formatter
    func formatDate(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    //Add task functions
    func addTaskFunc() {
        if checkForm() {
            let task = Task()
            task.name = nameTF.text
            task.description = descrTF.text
            task.createdDate = formatDate(Date())
            task.createdBy = user.name
            
            addTask(user.token!, task)
            clearForm()
            
            makeAlert(title: "Success", message: "Task has been added")
        }
    }
    
    
    func addTask(_ token: String, _ task: Task) {
        let taskRequest = TaskRequest.init(projectId: selectedProject.id!, endpoint: "")
        
        taskRequest.addTask(token, task, completion: {result in
            switch result {
            case .success(let task):
                print("Task: \(task.name!) added")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    // Fetch all projects
    func getAllProjects(_ token: String) {
            let projectRequest = ProjectRequest.init(endpoint: "")
            
            projectRequest.getAllProject(token, completion: {result in
                switch result{
                case .success(let projects):
                    print("Projects fetched")
                    self.projects = projects
                    print(projects.count)
                    self.projects.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
}

