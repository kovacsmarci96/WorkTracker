//
//  TasksVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation
import UIKit

extension TasksVC {
    
    
    // MARK: - URLRequests
    
    func getAllProjects(_ token:String,_ semaphore: DispatchSemaphore) {
            let projectRequest = ProjectRequest.init(endpoint: "")
            
            projectRequest.getAllProject(token, completion: {result in
                switch result{
                case .success(let projects):
                    print("Projects fetched")
                    self.projects = projects
                    print(projects.count)
                    self.projects.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                    semaphore.signal()
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
    
    func getAllTask(_ projId: String, _ token: String) {
        let taskRequest = TaskRequest.init(projectId: projId, endpoint: "")
            
            taskRequest.getAllTask(token, completion: {result in
                switch result{
                case .success(let fetchedTasks):
                    print("Tasks fetched")
                    self.append(fetchedTasks)
                    print("Tasks: \(fetchedTasks.count)")
                    self.tasks.sort { $0.name!.lowercased() < $1.name!.lowercased() }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
    
    func deleteTask(_projId: String, _ taskId: String, _ token: String) {
        let taskRequest = TaskRequest.init(projectId: _projId, endpoint: "\(taskId)/delete")
        
        taskRequest.deleteTask(token, completion: {result in
            switch result{
            case .success(let task):
                print("Task deleted \(task.name!)")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    // MARK: - Helpers to fetch tasks
    
    func fetchTasks(_ semaphore: DispatchSemaphore) {
        for project in projects {
            getAllTask(project.id!, user.token!)
        }
        semaphore.signal()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.tableView.reloadData()
        }
    }
    
    func append(_ fetchedTasks: [Task]){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for task in fetchedTasks {
                if !(self.tasks.contains(task)) {
                    self.tasks.append(task)
                }
            }
        }
    }
    
    func getTasksForProject(_ id: String) -> [Task] {
        var projectTasks = [Task]()
        for task in tasks {
            if task.projectId! == id {
                projectTasks.append(task)
            }
        }
        return projectTasks
    }
    
}
