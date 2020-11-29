//
//  ProjectVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation
import UIKit
import Charts

extension ProjectVC: UITableViewDelegate {}

extension ProjectVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tasks"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectTaskCell") as! ProjectTaskCell
        
        cell.taskNameTF.text = tasks[indexPath.row].name
        cell.taskDescrTF.text = tasks[indexPath.row].description
        cell.taskHourTF.text = String(Int(tasks[indexPath.row].taskHour!)) + " hours"
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProjectVC {
    
    // MARK: - Updating project functions
    
    func checkForm() -> Bool {
        if projectNameTF.text == "" {
            makeAlert(title: "Error", message: "Please add a description.")
            return false
        }
        if descriptionTF.text == "" {
            makeAlert(title: "Error", message: "Please add a task name.")
            return false
        }
        return true
    }
    
    func updateProject() {
        if (project.name == projectNameTF.text && project.description == descriptionTF.text) {
            makeAlert(title: "Error", message: "Nothing has changed.")
        } else if checkForm() {
            let project = ProjectAdd()
            project.ProjectDescription = descriptionTF.text
            project.ProjectName = projectNameTF.text
            
            updateRequest(project)
            makeAlert(title: "Success", message: "\(project.ProjectName!) has been updated.")
        }
    }
    
    func updateRequest(_ project: ProjectAdd) {
        let projectRequest = ProjectRequest.init(endpoint: "\((self.project.id)!)")
        
        projectRequest.updateProject(user.token!, project, completion: {result in
            switch result {
            case .success(let project):
                print("Project: \(project.ProjectName!) updated")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func getAllTask(_ token: String,_ projId: String,_ semaphore: DispatchSemaphore) {
        let taskRequest = TaskRequest.init(projectId: projId ,endpoint: "")
            
            taskRequest.getAllTask(token, completion: {result in
                switch result{
                case .success(let fetchedTasks):
                    self.tasks = fetchedTasks
                    print("Tasks fetched")
                    self.tasks.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                    semaphore.signal()
                case .failure(let error):
                    print("Error: \(error)")
                }
            })

    }
    
    func getTaskHour(_ token: String,_ projId: String, _ taskId: String) {
        let taskRequest = TaskRequest.init(projectId: projId ,endpoint: "\(taskId)/work")
            
            taskRequest.getTaskHour(token, completion: {result in
                switch result{
                case .success(let fetchedHour):
                    self.appendHour(taskId, fetchedHour)
                    print("Taskhours fetched")
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    
    // MARK: - These functions append task hours to task
    
    func fetchTaskHours(_ semaphore: DispatchSemaphore) {
        for task in tasks {
            getTaskHour(user.token!, project.id!, task.id!)
        }
        semaphore.signal()
    }
    
    func appendHour(_ taskId: String,_ fetchedHour: Double) {
        for task in tasks {
            if task.id == taskId {
                task.taskHour = fetchedHour
            }
        }
    }
    
    
    // MARK: - This function makes the BarChart
    
    func setupBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: viewForChart.frame.size.width, height: viewForChart.frame.size.height)
        barChart.center = viewForChart.center
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        
        viewForChart.addSubview(barChart)
        
        var taskEntries = [BarChartDataEntry]()
        var taskNames = [String]()
        
        for i in 0..<tasks.count {
            taskEntries.append((BarChartDataEntry(x: Double(i), y: tasks[i].taskHour!)))
        }
        
        for task in tasks {
            taskNames.append(task.name!)
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
    }
    
    
}
