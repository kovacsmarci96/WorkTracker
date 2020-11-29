//
//  ProjectsVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import UIKit

class ProjectsVC: UITableViewController {
    
    // MARK: - Variables
    
    var projects = [Project]()
    var user = User()
    

    // MARK: - View functions
    
    override func viewDidLoad() {
        setupTabBar()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            self.getAllProjects(self.user.token!, semaphore)
            semaphore.wait()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TabBar setup
    
    func setupTabBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        self.navigationItem.title = "Projects"
    }
    
    
    // MARK: - ButtonTapped
    
    @objc func addTapped() {
        let slideVC = storyboard?.instantiateViewController(identifier: "addProjectVC") as! AddProjectView
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.user = user
        slideVC.delegate = self
        self.present(slideVC, animated: true, completion: nil)
    }

    
    
    // MARK: - URLRequests
    
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
                    print("Error: \(error)")
                }
            })
        }
    
    // MARK: - Tableview setup

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectsCell", for: indexPath) as! ProjectCell
        
        cell.nameLabel.text = projects[indexPath.row].name
        cell.descriptionLabel.text = projects[indexPath.row].description
        
        
        cell.layer.borderWidth = 10.0
        cell.layer.cornerRadius = 50.0
        cell.layer.borderColor = UIColor.white.cgColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "projectVC") as! ProjectVC
        vc.project = projects[indexPath.row]
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteProject(projects[indexPath.row].id!, user.token!)
            let project = projects[indexPath.row]
            projects.remove(at: indexPath.row)
            makeAlert(title: "Success", message: "\(project.name!) has been deleted.")
            tableView.reloadData()
        }
    }
    
    func deleteProject(_ projId: String, _ token: String) {
        let projectRequest = ProjectRequest.init(endpoint: "\(projId)/delete")
        
        projectRequest.deleteProject(token, completion: {result in
            switch result{
            case .success(let project):
                print("Project deleted")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }


}
