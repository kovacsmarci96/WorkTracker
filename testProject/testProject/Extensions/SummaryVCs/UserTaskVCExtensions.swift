//
//  UserTaskVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import Foundation
import UIKit
import Charts

extension UserTaskVC: UITableViewDelegate {}

extension UserTaskVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskWorks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workCell", for: indexPath) as! WorkCell
        
        cell.dateLabel.text = formatDate(taskWorks[indexPath.row].createdDate!)
        cell.hourLabel.text = String(Int(taskWorks[indexPath.row].time!)) + " hours"
        cell.commentLabel.text = taskWorks[indexPath.row].comment
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Works you reported on this task"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "userWorkVC") as! UserWorkVC
        vc.work = taskWorks[indexPath.row]
        vc.project = project
        vc.task = task
        vc.tasks = tasks
        vc.projects = projects
        vc.user = user
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if taskWorks.count == 1 {
                self.navigationController?.popViewController(animated: true)
            }
            deleteWorkDelegate?.deleteWork(taskWorks[indexPath.row], taskWorks.count, task)
            deleteWork(project.id!, task.id!, taskWorks[indexPath.row].id!)
            taskWorks.remove(at: indexPath.row)
            tableView.reloadData()
            self.viewDidLayoutSubviews()
        }
    }
}

extension UserTaskVC: UpdateWorkDelegate {
    func updateWork(_ work: Work, _ task: Task) {
        let element = taskWorks.first(where: {$0.id == work.id})
        let elementIndex = taskWorks.firstIndex(of: element!)
        taskWorks.remove(at: elementIndex!)
        taskWorks.append(work)
        updateTaskDelegate?.updateTask(task, work)
        updateSummaryDelegate?.updateSummaryTask(work)
        self.tableView.reloadData()
        self.viewDidLayoutSubviews()
    }
}

extension UserTaskVC {
    
    // MARK: - This fuction deletes a work from the database
    
    func deleteWork(_ projectId: String,_ taskId: String,_ workId: String) {
        let workRequest = WorkRequest.init(projectId: projectId, taskId: taskId, endpoint: "workItems/\(workId)")
        
        workRequest.deleteWork(user.token!, completion: {result in
            switch result {
            case .success(let work):
                print("Work: \(work.comment!) has been deleted")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    // MARK: - This function fetch the works to this task
    
    func fetchTaskWorks() {
        for work in works {
            if (work.taskId! == task.id!) {
                if !(taskWorks.contains(work)){
                    taskWorks.append(work)
                }
            }
        }
        self.taskWorks.sort { $0.createdDate! < $1.createdDate! }
    }
    
    // MARK: - Setup BarChart
    
    func setupBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: viewForChart.frame.size.width-32, height: viewForChart.frame.size.height + 30)
        barChart.center.x = viewForChart.center.x - 16
        barChart.center.y = viewForChart.center.y + 7
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        
        viewForChart.addSubview(barChart)
        
        
        var workEntries = [BarChartDataEntry]()
        
        for i in 0..<taskWorks.count {
            workEntries.append((BarChartDataEntry(x: Double(i), y: taskWorks[i].time!)))
        }
        
        var workDates = [String]()
        for work in taskWorks {
            workDates.append(work.comment!)
        }
        
        barChart.xAxis.labelCount = workEntries.count
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:workDates)
        barChart.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        barChart.leftAxis.labelFont = UIFont(name: "Helvetica Neue", size: 15)!
        
        barChart.leftAxis.axisMinimum = 0

        let set = BarChartDataSet(entries: workEntries)
        set.valueFont = UIFont(name: "Helvetica Neue", size: 12)!
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        barChart.data = data
        set.label = "Tasks"
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
    
    // MARK: - Format date to new style
    
    func formatStringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString)!
        return date
    }
    
    func formatDate(_ date: String) -> String {
        let split = date.components(separatedBy: "-")
        
        let date1 = formatStringToDate(date)
        let weekday = date1.dayNameOfWeek()
        
        let date2 = split[0] + "." + split[1] + "." + split[2] + ". - "
        let date3 = date2 + weekday!
        
        return date3
    }
}

extension Date {
    func dayNameOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
