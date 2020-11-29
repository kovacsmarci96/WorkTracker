//
//  UserProjectVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import Foundation
import UIKit
import Charts


extension UserProjectVC: UITableViewDelegate{}

extension UserProjectVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tasks you worked on in this project"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectTasks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "userTaskVC") as! UserTaskVC
        vc.task = projectTasks[indexPath.row]
        vc.works = works
        vc.user = user
        vc.tasks = userTasks
        vc.updateTaskDelegate = self
        vc.projects = userProjects
        vc.deleteWorkDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        
        cell.taskName.text = projectTasks[indexPath.row].name
        cell.descrLabel.text = projectTasks[indexPath.row].description
        cell.hourLabel.text = String(Int(taskHours[projectTasks[indexPath.row].id!]!)) + " hours"
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor
        
        
        return cell
    }
}

extension UserProjectVC {
    
    func filterTasksToProject() {
        for task in userTasks {
            if !(projectTasks.contains(task)) {
                if (task.projectId! == project.id!){
                    projectTasks.append(task)
                }
            }
        }
    }
    
    func fetchProjectHours() {
        for task in projectTasks {
            projectHours.updateValue([], forKey: task.id!)
        }
        
        for (key,value) in taskHours {
            for task in projectTasks {
                if task.id! == key {
                    print("Key: \(key)")
                    print("Task: \(task.id!)")
                    projectHours[task.id!]?.append(value)
                }
            }
        }
    }
    
    func fetchProjectWorks() {
        for (key, value) in taskWorks {
            for task in projectTasks {
                if key == task.id! {
                    projectWorks.updateValue(value, forKey: key)
                }
            }
        }
    }
    
    func count() {
        filterTasksToProject()
        fetchProjectWorks()
        countWorkingHoursPerTask(projectWorks)
        fetchProjectHours()
    }
    
    func update() {
        countWorkingHoursPerTask(projectWorks)
        fetchProjectHours()
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
    
    func updateHour(_ work : Work,_ task: Task) {
        for (key, value) in projectWorks {
            if (key == task.id) {
                for wValue in value {
                    if wValue.id == work.id {
                        wValue.time = work.time
                    }
                }
            }
        }
    }
    
    func setupBarChart(_ taskHoursInput: [String : Double]) {
        barChart.frame = CGRect(x: 0, y: 0, width: viewForChart.frame.size.width-32, height: viewForChart.frame.size.height)
        barChart.center = viewForChart.center
        barChart.center.x = viewForChart.center.x-16
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        
        viewForChart.addSubview(barChart)
        
        
        var taskEntries = [BarChartDataEntry]()
        
        var i = 0
        for (_, value) in taskHoursInput {
            taskEntries.append((BarChartDataEntry(x: Double(i), y: value)))
            i += 1
        }
        
        barChart.xAxis.labelCount = taskHoursInput.count
        
        var taskNames = [String]()
        for entry in taskEntries {
            for (key, value) in taskHoursInput {
                if Double(entry.y) == value {
                    if let task = projectTasks.first(where: {$0.id == key}) {
                        taskNames.append(task.name!)
                    }
                }
            }
        }
        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: taskNames)
        barChart.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.axisMinimum = 0
        
        let set = BarChartDataSet(entries: taskEntries)
        set.valueFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        barChart.data = data
        set.label = "Tasks"
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
}

extension UserProjectVC: UpdateTaskDelegate {
    func updateTask(_ task: Task,_ work: Work) {
        let element = works.first(where: {$0.id == work.id})
        let elementIndex = works.firstIndex(of: element!)
        works.remove(at: elementIndex!)
        works.append(work)
        let taskElement = userTasks.first(where: {$0.id == task.id})
        let taskElementIndex = userTasks.firstIndex(of: taskElement!)
        userTasks.remove(at: taskElementIndex!)
        userTasks.append(task)
        print("TaskHours : \(taskHours)")
        updateHour(work, task)
        update()
        setupBarChart(taskHours)
        delegate?.refreshProjects(work)
    }
}

extension UserProjectVC: DeleteWorkDelegate {
    func deleteWork(_ work: Work,_ taskWorkCount: Int,_ task: Task) {
        let workIndex = works.firstIndex(of: work)
        if taskWorkCount == 1 {
            print("TaskWorkCount \(taskWorkCount)")
            if let taskIndex = projectTasks.firstIndex(of: task) {
                projectTasks.remove(at: taskIndex)
                works.remove(at: taskIndex)
                delete(task, work)
                update()
                taskHours.removeValue(forKey: task.id!)
                delegate?.refreshProjects(work)
                setupBarChart(taskHours)
            }
        } else {
            delete(task, work)
            works.remove(at: workIndex!)
            update()
            setupBarChart(taskHours)
            delegate?.refreshProjects(work)
            tableView.reloadData()
        }
        tableView.reloadData()
        if projectTasks.count == 0 {
            delegate?.refreshProjects(work)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func delete(_ task: Task, _ deletableWork: Work) {
        
        var works = [Work]()
        for (key, value) in projectWorks {
            if (key == task.id!) {
                works = value
                projectWorks.removeValue(forKey: key)
            }
        }
        works = works.filter { $0.id! != deletableWork.id! }
        projectWorks.updateValue(works, forKey: task.id!)
    }
}
