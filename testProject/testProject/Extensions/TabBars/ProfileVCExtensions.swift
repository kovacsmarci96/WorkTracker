//
//  ProfileVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation
import UIKit
import Charts

extension ProfileVC : UIPickerViewDelegate {
}

extension ProfileVC: UIPickerViewDataSource {
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
        countHours()
        chooser.resignFirstResponder()
        viewDidLayoutSubviews()
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
}

extension ProfileVC {
    func getAllProjects(_ token: String,_ semaphore: DispatchSemaphore) {
            let projectRequest = ProjectRequest.init(endpoint: "")
            
            projectRequest.getAllProject(token, completion: {result in
                switch result{
                case .success(let projects):
                    print("Projects fetched")
                    self.projects = projects
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
    
    // MARK: - These functions counts the working hours / task
    
    
    func fetchUserWorks() {
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
            for work in filteredWorks {
                if work.taskId == task.id {
                    if !(userTasks.contains(task)){
                        userTasks.append(task)
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
    
    
    func countWorkingHoursPerTask(dict: [String : [Work]]) {
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
    
    func countHours() {
        fetchUserWorks()
        filterToDate(chooser.text!, userWorks)
        print("Filtered: \(filteredWorks.count)")
        fetchUserTasks()
        fetchTaskWorks()
        countWorkingHoursPerTask(dict: taskWorks)
    }

    
    // MARK: - This function sets up the BarChart
    
    func setupBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: viewForChart.frame.size.width, height: viewForChart.frame.size.height)
        barChart.center.y = viewForChart.center.y-50
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        
        viewForChart.addSubview(barChart)
        
        
        var taskEntries = [BarChartDataEntry]()
        
        var i = 0
        for (_, value) in taskHours {
            taskEntries.append((BarChartDataEntry(x: Double(i), y: Double(value))))
            i += 1
        }
        var taskNames = [String]()
        for entry in taskEntries {
            for (key, value) in taskHours {
                if Double(entry.y) == value {
                    if let task = tasks.first(where: {$0.id == key}) {
                        taskNames.append(task.name!)
                    }
                }
            }
        }
        
        barChart.xAxis.labelCount = taskEntries.count
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:taskNames)
        barChart.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        
        barChart.leftAxis.axisMinimum = 0

        let set = BarChartDataSet(entries: taskEntries)
        set.valueFont = UIFont(name: "Helvetica Neue", size: 12)!
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        barChart.data = data
        set.label = "Tasks"
    }
    
    // MARK: - These functions filters works by dates
    
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
    
    func formatString(_ date: String) -> String {
        let split = date.components(separatedBy: "-")
        var day = split[2]
        if let tRange = day.range(of: "T") {
            day.removeSubrange(tRange.lowerBound..<day.endIndex) }
        let date = split[0] + "-" + split[1] + "-" + day
        return date
    }


}


