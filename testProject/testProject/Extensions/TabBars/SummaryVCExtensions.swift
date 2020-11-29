//
//  SummaryVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 27..
//

import Foundation
import UIKit
import Charts

extension SummaryVC: UIPickerViewDelegate {}

extension SummaryVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteringOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteringOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cell.animate()
        chooser.text = String(filteringOptions[row])
        chooser.resignFirstResponder()
        count()
        cView.reloadData()
        tableView.reloadData()
    }
}

extension SummaryVC: UITableViewDelegate {}

extension SummaryVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showProjects {
            return "Projects you worked on"
        }
        if showTasks {
            return "Tasks you worked on"
        }
        if showWorks {
            return "Works you made"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showProjects {
            return userProjects.count
        }
        if showTasks {
            return userTasks.count
        }
        if showWorks {
            return filteredWorks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell",for: indexPath) as! AllCell
        if showProjects {
            cell.nameLabel.text = userProjects[indexPath.row].name
            cell.descLabel.text = userProjects[indexPath.row].description
            cell.hourLabel.text = String(Int(projectHours[userProjects[indexPath.row].id!]!)) + " hours"
        }
        if showTasks {
            cell.nameLabel.text = userTasks[indexPath.row].name
            cell.descLabel.text = userTasks[indexPath.row].description
            cell.hourLabel.text = String(Int(taskHours[userTasks[indexPath.row].id!]!)) + " hours"
        }
        if showWorks {
            cell.nameLabel.text = formatDate(filteredWorks[indexPath.row].createdDate!)
            cell.descLabel.text = filteredWorks[indexPath.row].comment
            cell.hourLabel.text = String(Int(filteredWorks[indexPath.row].time!)) + " hours"
        }
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showProjects {
            let vc = storyboard?.instantiateViewController(identifier: "userProjectVC") as! UserProjectVC
            vc.project = userProjects[indexPath.row]
            vc.userTasks = userTasks
            vc.taskHours = taskHours
            vc.userProjects = userProjects
            vc.user = user
            vc.works = filteredWorks
            vc.taskWorks = taskWorks
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if showTasks {
            let vc = storyboard?.instantiateViewController(identifier: "userTaskVC") as! UserTaskVC
            vc.task = userTasks[indexPath.row]
            vc.works = filteredWorks
            vc.projects = userProjects
            vc.user = user
            vc.tasks = userTasks
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if showWorks {
            let vc = storyboard?.instantiateViewController(identifier: "userWorkVC") as! UserWorkVC
            vc.work = filteredWorks[indexPath.row]
            vc.projects = userProjects
            vc.tasks = userTasks
            vc.user = user
            vc.updateSummaryDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SummaryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SummaryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chartCell", for: indexPath) as! PieChartCell
        
        cell.projects = projects
        cell.tasks = tasks
        cell.works = filteredWorks
        cell.projectHours = projectHours
        cell.taskHours = taskHours
        cell.state = states[indexPath.row]
        
        return cell
    }
}

extension SummaryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width , height: self.view.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
        if page == -1 {
            changeFromTaskToProject()
            self.cView.reloadData()
        }
        if page == 0 {
            changeFromProjectToTask()
            self.cView.reloadData()
        }
        if page == 1 {
            changeFromTaskToWork()
            self.cView.reloadData()
        }
    }
}

extension SummaryVC {
    
    //MARK: - DateHelpers
    
    func formatDate(_ date: String) -> String {
        let split = date.components(separatedBy: "-")
        
        let date1 = formatStringToDate(date)
        let weekday = date1.dayNameOfWeek()
        
        let date2 = split[0] + "." + split[1] + "." + split[2] + ". - "
        let date3 = date2 + weekday!
        
        return date3
    }
    
    // MARK: - LogOut functions
    
    @objc func logOut() {
        makeLogOutAlert(title: "Logging out", message: "Do you really want to log out?")
    }
    
    
    func makeLogOutAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            DispatchQueue.main.async {
                self.saveLoggedOutState()
            }
            print("User logged out")
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func saveLoggedOutState() {
        UserDefaults.standard.setValue(false, forKey: "loggedIn")
        UserDefaults.standard.setValue("", forKey: "token")
        UserDefaults.standard.setValue("", forKey: "name")
        UserDefaults.standard.setValue("", forKey: "email")
        UserDefaults.standard.setValue("", forKey: "id")
        UserDefaults.standard.setValue("", forKey: "role")
    }
    
    // MARK: - API Requests
    
    func getAllProjects(_ token: String,_ semaphore: DispatchSemaphore) {
            let projectRequest = ProjectRequest.init(endpoint: "")
            
            projectRequest.getAllProject(token, completion: {result in
                switch result{
                case .success(let fetchedProjects):
                    print("Projects fetched")
                    self.projects = fetchedProjects
                    self.projects.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                    semaphore.signal()
                case .failure(let error):
                    print("Project Error: \(error)")
                }
            })
        }
    
    func getAllTask(_ projId: String, _ token: String,_ semaphore: DispatchSemaphore) {

        let taskRequest = TaskRequest.init(projectId: projId, endpoint: "")
            
            taskRequest.getAllTask(token, completion: {result in
                switch result{
                case .success(let fetchedTasks):
                    print("Tasks fetched")
                    self.appendTask(fetchedTasks)
                    self.tasks.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                    semaphore.signal()
                case .failure(let error):
                    print("Task Error: \(error)")
                }
            })
        }
    
    func getAllWork(_ projId: String,_ taskId: String,_ filter: String) {
        let workRequest = WorkRequest.init(projectId: projId, taskId: taskId, endpoint: "workItems")
        
        workRequest.getAllWork(user.token!, completion: {result in
            switch result{
            case .success(let fetchedWorks):
                self.appendWork(fetchedWorks)
                print("Works fetched")
                self.works.sort { $0.createdBy!.lowercased() < $1.createdBy!.lowercased() }
            case .failure(let error):
                print("Work Error: \(error)")
            }
        })
    }
    
    // MARK: - Help functions for the API Requests
    
    func appendTask(_ fetchedTasks: [Task]){
        for task in fetchedTasks {
            if !(self.tasks.contains(task)) {
                self.tasks.append(task)
            }
        }
    }
    
    func appendWork(_ fetchedWorks: [Work]) {
        for work in fetchedWorks {
            if !(self.works.contains(work)) {
                self.works.append(work)
            }
        }
    }
    
    // MARK: - This function fetches all the tasks and works
    
    func fetchTasks(_ semaphore: DispatchSemaphore,_ filter: String) {
        for project in projects {
            getAllTask(project.id!, user.token!, semaphore)
            semaphore.wait()
            for task in tasks {
                if task.projectId == project.id {
                    getAllWork(project.id!, task.id!, filter)
                }
            }
        }
    }
    
    // MARK: - These functions fetches UserWorks, UserTasks and UserProjects
    
    func fetchUserWorks() {
        userWorks.removeAll()
        for work in works {
            if !(userWorks.contains(work)) {
                if (work.createdBy == user.name) {
                    work.createdDate = formatString(work.createdDate!)
                    userWorks.append(work)
                }
            }
        }
    }
    
    func fetchUserTasks() {
        userTasks.removeAll()
        for task in tasks {
            for work in filteredWorks
            {
                if work.taskId == task.id {
                    if !(userTasks.contains(task)){
                        userTasks.append(task)
                    }
                }
            }
        }
    }
    
    func fetchUserProject() {
        userProjects.removeAll()
        for project in projects {
            for task in userTasks {
                if task.projectId == project.id {
                    if !(userProjects.contains(project)) {
                        userProjects.append(project)
                    }
                }
            }
        }
    }
    
    func fetchTaskWorks() {
        taskWorks.removeAll()
        for task in userTasks {
            taskWorks.updateValue([], forKey: task.id!)
        }
        for work in filteredWorks {
            let taskID = work.taskId!
            if taskWorks[taskID] != nil {
                taskWorks[taskID]!.append(work)
            }
        }
    }
    
    func fetchProjectWorks() {
        projectWorks.removeAll()
        for project in userProjects {
            projectWorks.updateValue([], forKey: project.id!)
        }
        for work in filteredWorks {
            for task in userTasks {
                let projectId = task.projectId!
                let taskId = work.taskId!
                if taskId == task.id! {
                    if projectWorks[projectId] != nil {
                        projectWorks[projectId]?.append(work)
                    }
                }
            }
        }
    }
    
    // MARK: - These functions counts the working hours / project / task
    
    func countWorkingHoursPerProject(_ dict: [String : [Work]]) {
        projectHours.removeAll()
        var sum = 0.0
        for (key, value) in dict {
            for numb in value {
                sum += numb.time!
            }
            projectHours.updateValue(sum, forKey: key)
            sum = 0
        }
    }
    
    func countWorkingHoursPerTask(_ dict: [String : [Work]]) {
        taskHours.removeAll()
        var sum = 0.0
        for (key, value) in dict {
            for numb in value {
                sum += numb.time!
            }
            taskHours.updateValue(sum, forKey: key)
            sum = 0
        }
    }
    
    func count() {
        fetchUserWorks()
        filterToDate(chooser.text!, userWorks)
        fetchUserTasks()
        fetchUserProject()
        fetchTaskWorks()
        fetchProjectWorks()
        countWorkingHoursPerTask(taskWorks)
        countWorkingHoursPerProject(projectWorks)
    }
    
    
    // MARK: - These functions filters the dates
    
    func filterToDate(_ filter: String,_ userWorks: [Work]){
        let today = formatDateToDate(Date())
        
        if(filter == "All") {
            filteredWorks = userWorks
        }
        if(filter == "Today") {
            filteredWorks.removeAll()
            print("Today")
            for work in userWorks {
                if (formatStringToDate(work.createdDate!) == today) {
                    filteredWorks.append(work)
                }
            }
        }
        if(filter == "This week") {
            filteredWorks.removeAll()
            print("This week")
            let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)
            for work in userWorks {
                if (lastWeek! <= formatStringToDate(work.createdDate!) && formatStringToDate(work.createdDate!) <= today) {
                    filteredWorks.append(work)
                }
            }
        }
        if filter == "This month" {
            filteredWorks.removeAll()
            print("This month")
            let lastMonth = Calendar.current.date(byAdding: .day, value: -31, to: today)
            for work in userWorks {
                if (lastMonth! <= formatStringToDate(work.createdDate!) && formatStringToDate(work.createdDate!) <= today) {
                    filteredWorks.append(work)
                }
            }
        }
    }

    func formatStringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString)!
        return date
    }

    func formatDateToDate(_ date: Date) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return formatStringToDate(dateString)
    }

    
    // MARK: - Helper function for transofrming creationDate
    
    func formatString(_ date: String) -> String {
        let split = date.components(separatedBy: "-")
        var day = split[2]
        if let tRange = day.range(of: "T") {
            day.removeSubrange(tRange.lowerBound..<day.endIndex) }
        let date = split[0] + "-" + split[1] + "-" + day
        return date
    }
    
    // MARK: - Slide methods
    
    func changeFromProjectToTask() {
        
        showProjects = false
        showTasks = true
        showWorks = false
        
        
        let indexSet = IndexSet(integer: 0)
        
        tableView.reloadSections(indexSet, with: .left)
    }
    
    func changeFromTaskToProject() {
        
        showProjects = true
        showTasks = false
        showWorks = false
        
        let indexSet = IndexSet(integer: 0)

        tableView.reloadSections(indexSet, with: .right)
    }
    
    func changeFromTaskToWork() {

        showProjects = false
        showTasks = false
        showWorks = true
        
        let indexSet = IndexSet(integer: 0)
        
        tableView.reloadSections(indexSet, with: .left)
    }
    
    func changeFromWorkToTask() {
        showProjects = false
        showTasks = true
        showWorks = false
        
        let indexSet = IndexSet(integer: 0)
        
        tableView.reloadSections(indexSet, with: .right)
    }
}

extension SummaryVC: RefreshProjectDelegate {
    func refreshProjects(_ work: Work) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewWillAppear(true)
            if !(self.filteredWorks.count == 0) {
                let index = self.filteredWorks.firstIndex(of: work)
                self.filteredWorks.remove(at: index!)
            }
        }
    }
}

extension SummaryVC: UpdateSummaryDelegate {
    func updateSummaryWork(_ work: Work) {
        self.viewWillAppear(true)
    }
}

extension SummaryVC: UpdateSummaryTaskDelegate {
    func updateSummaryTask(_ work: Work) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewWillAppear(true)
        }
    }
}
