//
//  TaskVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation
import UIKit
import Charts


// MARK: - TableView Delegate

extension TaskVC: UITableViewDelegate {
}

// MARK: - TableView Datasource

extension TaskVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Users worked on this task"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userWorkCell") as! TaskUserCell
        
        cell.nameLabel.text = users[indexPath.row]
        cell.hourLabel.text = String(Int(taskHours[users[indexPath.row]]!)) + " hours"
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor

        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension TaskVC {
    // MARK: - This function sets up the required color
    
    func setRedColor() {
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        let cgRequiredColor = CGColor(colorSpace: sRGB, components: [0.809147, 0, 0, 1])!
        requiredColor = UIColor(cgColor: cgRequiredColor)
    }
    
    // MARK: - These functions doing the editing
    
    @objc func editTapped() {
        editing()
    }
    
    func editing() {
        taskNameTF.borderStyle = .roundedRect
        descriptionTF.borderStyle = .roundedRect
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action:  nil)
        taskNameTF.isEnabled = true
        descriptionTF.isEnabled = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    }
    
    // MARK: - Task Update functions
    
    @objc func doneEditing() {
        taskNameTF.borderStyle = .none
        descriptionTF.borderStyle = .none
        updateTask()
        taskNameTF.isEnabled = false
        descriptionTF.isEnabled = false
        self.navigationItem.title = taskNameTF.text
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    func checkForm() -> Bool {
        if descriptionTF.text == "" {
            makeAlert(title: "Error", message: "Please add a description.")
            return false
        }
        if taskNameTF.text == "" {
            makeAlert(title: "Error", message: "Please add a task name.")
            return false
        }
        return true
    }
    
    func updateRequest(_ token: String, _ projId: String, _ task: Task) {
        let taskRequest = TaskRequest.init(projectId: projId, endpoint: "\(task.id!)")
        
        taskRequest.updateTask(user.token!, task, completion: {result in
            switch result {
            case .success(let task):
                print("Task: \(task.name!) updated")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func updateTask() {
        if(taskNameTF.text == task.name && descriptionTF.text == task.description) {
            makeAlert(title: "Error", message: "Nothing has changed.")
        } else if checkForm() {
            let updatableTask = Task()
            updatableTask.id = self.task.id
            updatableTask.createdBy = self.task.createdBy
            updatableTask.description = descriptionTF.text
            updatableTask.name = taskNameTF.text

            updateRequest(user.token!, project.id!, updatableTask)
            makeAlert(title: "Success", message: "\(updatableTask.name!) has been updated.")
        }
    }
    
    func getAllWork(_ projId: String,_ taskId: String,_ semaphore: DispatchSemaphore) {
        let workRequest = WorkRequest.init(projectId: projId, taskId: taskId, endpoint: "workItems")
        
        workRequest.getAllWork(user.token!, completion: {result in
            switch result{
            case .success(let works):
                self.works = works
                print("Works fetched \(self.works.count)")
                self.works.sort { $0.createdBy!.lowercased() < $1.createdBy!.lowercased() }
                semaphore.signal()
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func fetchUser(_ filteredWorks: [Work]) {
        users.removeAll()
        for work in filteredWorks {
            if !(users.contains(work.createdBy!)) {
                users.append(work.createdBy!)
            }
        }
    }
    
    func setupBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: viewForChart.frame.size.width, height: viewForChart.frame.size.height)
        barChart.center = viewForChart.center
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        
        viewForChart.addSubview(barChart)
        
        
        var workEntries = [BarChartDataEntry]()
        var userNames = [String]()
        

        var i = 0
        for (_, value) in taskHours {
            workEntries.append((BarChartDataEntry(x: Double(i), y: Double(value))))
            i += 1
        }
        
        for entry in workEntries {
            for (key,value) in taskHours {
                if entry.y == value {
                    userNames.append(key)
                }
            }
        }
        
        barChart.xAxis.labelCount = userNames.count
        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: userNames)
        barChart.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.axisMinimum = 0
        
        let set = BarChartDataSet(entries: workEntries)
        set.valueFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        barChart.data = data
    }
    
    func filterToDate(_ filter: String,_ userWorks: [Work]) -> [Work] {
        let today = formatDateToDate(Date())
        var filteredWorks = [Work]()
        
        if(filter == "All") {
            filteredWorks = userWorks
        }
        if(filter == "Today") {
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
        
        return filteredWorks
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
    
    func formatString(_ date: String) -> String {
        let split = date.components(separatedBy: "-")
        var day = split[2]
        if let tRange = day.range(of: "T") {
            day.removeSubrange(tRange.lowerBound..<day.endIndex) }
        let date = split[0] + "-" + split[1] + "-" + day
        return date
    }
    
    func fetchUserWorks(_ filter: String) {
        userWorks.removeAll()
        for work in works {
            work.createdDate = formatString(work.createdDate!)
        }
        let filteredWorks = filterToDate(filter, works)
        fetchUser(filteredWorks)
        for user in users {
            userWorks.updateValue([], forKey: user)
        }
        for work in filteredWorks {
            let userName = work.createdBy
            let workTime = work.time
            if userWorks[userName!] != nil {
                userWorks[userName!]!.append(workTime!)
            }
        }
    }
    
    func countWorkingHoursPerTask(dict: [String : [Double]]){
        taskHours.removeAll()
        var sum = 0.0
        for (key, value) in dict {
            for numb in value {
                sum += numb
            }
            taskHours.updateValue(sum, forKey: key)
            sum = 0
        }
        print("Tasks:  \(taskHours)")
    }
    
    func countHours(_ filter: String) {
        fetchUserWorks(filter)
        countWorkingHoursPerTask(dict: userWorks)
    }
}

extension TaskVC : UIPickerViewDelegate {
}

extension TaskVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteringOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteringOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chooser.text = String(filteringOptions[row])
        let filter = chooser.text!
        countHours(filter)
        chooser.resignFirstResponder()
        usersTableView.reloadData()
        viewDidLayoutSubviews()
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
}
