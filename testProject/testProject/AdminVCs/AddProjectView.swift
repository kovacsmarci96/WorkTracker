//
//  AddProjectView.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

//
//  OverlayView.swift
//  WorkTracker
//
//  Created by Kovács Márton on 2020. 11. 24..
//

import UIKit

protocol AddProjectDelegate {
    func viewWillDismiss()
}

class AddProjectView: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var delegate: AddProjectDelegate?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descrTF: UITextField!
    
    var user = User()

    @IBAction func addTapped(_ sender: Any) {
        addProjectFunc()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    func checkForm() -> Bool {
        if nameTF.text == "" {
            makeAlert(title: "Error", message: "Please add a name.")
            return false
        }
        if descrTF.text == "" {
            makeAlert(title: "Error", message: "Please add a description.")
            return false
        }
        return true
    }
    
    func clearForm() {
        nameTF.text = ""
        descrTF.text = ""
        nameTF.resignFirstResponder()
        descrTF.resignFirstResponder()
    }
    
    func addProjectFunc() {
        if checkForm() {
            let project = ProjectAdd()
            project.ProjectName = nameTF.text
            project.ProjectDescription = descrTF.text
            
            
            clearForm()
            addProject(user.token!, project)
            makeAlertAdd(title: "Success", message: "\(project.ProjectName!) has been added!")
        }
        
    }
    
    func makeAlertAdd(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) {
            UIAlertAction in
            self.delegate?.viewWillDismiss()
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true)
    }
    

    
    func addProject(_ token: String, _ project: ProjectAdd) {
        let projectRequest = ProjectRequest.init(endpoint: "")

        projectRequest.addProject(token, project, completion: {result in
            switch result {
            case .success(let project):
                print("Project: \(project.ProjectName!) added")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }


    @objc func panGestureRecognizer(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        guard translation.y >= 0 else {return}
        
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    

}

