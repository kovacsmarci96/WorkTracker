//
//  TasksVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class TasksVC: UITableViewController {
    
    // MARK: - Variables
    
    var user = User()
    var projects = [Project]()
    var tasks = [Task]()
    
    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllProjects(self.user.token!, semaphore)
            semaphore.wait()
            self.fetchTasks(semaphore)
            semaphore.wait()
        }
    }

    
    // MARK: - NavBar setup
    func setupNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "Tasks"
    }
    
    // MARK: - Table view functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return projects[section].name!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let projectTasks = getTasksForProject(projects[section].id!)
        return projectTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath) as! TasksCell

        let projectTasks = getTasksForProject(projects[indexPath.section].id!)
        
        cell.taskNameTF.text = projectTasks[indexPath.row].name
        cell.taskDescrTF.text = projectTasks[indexPath.row].description
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "taskVC") as! TaskVC
        let projectTasks = getTasksForProject(projects[indexPath.section].id!)
        
        vc.task = projectTasks[indexPath.row]
        vc.project = projects[indexPath.section]
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let projectTasks = getTasksForProject(projects[indexPath.section].id!)
            let deletableTask = projectTasks[indexPath.row]
            deleteTask(_projId: deletableTask.projectId!, deletableTask.id!, user.token!)
            let index = tasks.firstIndex(where: {$0.name == deletableTask.name})
            tasks.remove(at: index!)
            makeAlert(title: "Success", message: "\(deletableTask.name!) has been deleted.")
            tableView.reloadData()
        }
    }
}
