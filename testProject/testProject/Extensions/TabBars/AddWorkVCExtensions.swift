//
//  AddWorkVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

extension AddWorkVC: UITableViewDelegate {
}

extension AddWorkVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedButton == btnSelectTask) {
            return tasks.count
        }
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooserCell") as! ChooserCell
        if (selectedButton == btnSelectTask) {
            cell.textLabel?.text = tasks[indexPath.row].name
            cell.backgroundColor = requiredColor
            cell.textLabel?.textColor = .white
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2.0
        } else {
            cell.textLabel?.text = projects[indexPath.row].name
            cell.backgroundColor = requiredColor
            cell.textLabel?.textColor = .white
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2.0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedButton == btnSelectTask) {
            btnSelectTask.setTitle(tasks[indexPath.row].name, for: .normal)
            selectedTask = tasks[indexPath.row]
        } else {
            btnSelectProject.setTitle(projects[indexPath.row].name, for: .normal)
            selectedProject = projects[indexPath.row]
            getAllTask(user.token!)
            btnSelectTask.setTitle("Select Task", for: .normal)
        }
        removeTransparentView()
    }
}

extension AddWorkVC: UIPickerViewDelegate {
}

extension AddWorkVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(hours[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        workHourTF.text = String(hours[row])
        workHourTF.resignFirstResponder()
        commentTF.resignFirstResponder()
    }
}

extension AddWorkVC {
    
    //This function checks if the form is valid
    func checkForm() -> Bool {
        if btnSelectProject.currentTitle == "Select Project" {
            makeAlert(title: "Error", message: "Please select a project.")
            return false
        }
        if btnSelectTask.currentTitle == "Select Task" {
            makeAlert(title: "Error", message: "Please select a task.")
            return false
        }
        if workHourTF.text == "" {
            makeAlert(title: "Error", message: "Please add a work hour.")
            return false
        }
        if dateTF.text == "" {
            makeAlert(title: "Error", message: "Please add a date.")
            return false
        }
        if commentTF.text == "" {
            makeAlert(title: "Error", message: "Please add a comment.")
            return false
        }
        return true
    }
    
    
    //This function clears the form
    func clearForm() {
        commentTF.text = ""
        dateTF.text = ""
        btnSelectProject.setTitle("Select Project", for: .normal)
        btnSelectTask.setTitle("Select Task", for: .normal)
        workHourTF.text = ""
        dateTF.resignFirstResponder()
        workHourTF.resignFirstResponder()
        commentTF.resignFirstResponder()
        tasks.removeAll()
    }
    
    
    //These functions makes the transparentviews
    func calculatePush() {
        if selectedButton == btnSelectTask {
            push = 180
            pushBack = push
            size = CGFloat(tasks.count)
        } else {
            push = 100
            pushBack = 180
            size = CGFloat(projects.count)
        }
    }
    
    
    func addTransparentView(frames: CGRect) {
        calculatePush()
        print("Push: \(self.push)")
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x + 16, y: frames.origin.y + frames.height + push, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 25
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))

        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { [self] in
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x+16, y: frames.origin.y + frames.height+push, width: frames.width, height: CGFloat(size * 43))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        print("Push: \(self.push)")
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x+16, y: frames.origin.y + frames.height+self.pushBack, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTF.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //This function sets the required color
    func setupRedColor() {
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        let cgRequiredColor = CGColor(colorSpace: sRGB, components: [0.809147, 0, 0, 1])!
        requiredColor = UIColor(cgColor: cgRequiredColor)
    }
    
    //Add a work
    func addWork(_ token: String, _ work: WorkAdd) {
        let workRequest = WorkRequest.init(projectId: selectedProject.id!, taskId: selectedTask.id!, endpoint: "workItems/new")
        
        workRequest.addWork(token, work, completion: {result in
            switch result {
            case .success(let work):
                print("Task: \(work.comment!) added")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    
    // Get Projects and Tasks
    func getAllProjects(_ token:String) {
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
    
    func getAllTask(_ token: String) {
        let taskRequest = TaskRequest.init(projectId: selectedProject.id! ,endpoint: "")
            
            taskRequest.getAllTask(token, completion: {result in
                switch result{
                case .success(let fetchedTasks):
                    print("Tasks fetched")
                    self.tasks = fetchedTasks
                    print(fetchedTasks.count)
                    self.tasks.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
   


}
