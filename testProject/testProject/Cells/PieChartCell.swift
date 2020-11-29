//
//  PieChartCell.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 27..
//

import UIKit
import Charts

class PieChartCell: UICollectionViewCell, ChartViewDelegate {
    
    // MARK: - Variables
    
    var pieChart = PieChartView()
    
    var projects = [Project]()
    var tasks = [Task]()
    var works = [Work]()
    
    var projectHours = [String : Double]()
    var taskHours = [String : Double]()
    
    var showProject = true
    var showTask = false
    var showWork = false
    
    var state = String()
    
    // MARK: - INIT functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pieChart.delegate = self
        animate()
    }
    
    override func layoutSubviews() {
        setupPieChart()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - This function animate the PieChart
    
    func animate() {
        pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
    
    // MARK: - This function sets up the PieChart
    
    func setupPieChart() {
        pieChart.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height-540)
        pieChart.center.y = contentView.center.y-270
        pieChart.center.x = contentView.center.x-5
        pieChart.legend.enabled = false
        
        contentView.addSubview(pieChart)
        var projectEntries = [ChartDataEntry]()
        var taskEntries = [ChartDataEntry]()
        var workEntries = [ChartDataEntry]()
        
        var i = 0
        for (_, value) in projectHours {
            projectEntries.append((BarChartDataEntry(x: Double(i), y: Double(value))))
            i += 1
        }
        
        var j = 0
        for (_, value) in taskHours {
            taskEntries.append((BarChartDataEntry(x: Double(i), y: Double(value))))
            j += 1
        }
        
        for k in 0..<works.count {
            workEntries.append((BarChartDataEntry(x: Double(k), y: works[k].time!)))
        }
        
        var set: PieChartDataSet = PieChartDataSet()
        
        if (state == "Project"){
            if(workEntries.isEmpty) {
                set.label = "No projects yet."
            } else {
                set = PieChartDataSet(entries:  projectEntries)
                set.label = "Projects"
                set.colors = ChartColorTemplates.colorful()
            }
        }
        
        if (state == "Task") {
            if(workEntries.isEmpty) {
                set.label = "No tasks yet"
            } else {
                set = PieChartDataSet(entries:  taskEntries)
                set.label = "Tasks"
                set.colors = ChartColorTemplates.colorful()
            }
        }
        
        if (state == "Work") {
            if(workEntries.isEmpty) {
                set.label = "No works yet."
            } else {
                set = PieChartDataSet(entries:  workEntries)
                set.label = "Works"
                set.colors = ChartColorTemplates.colorful()
            }
        }
        
        pieChart.centerText = set.label

        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.rotationWithTwoFingers = true
        animate()
    }
}
