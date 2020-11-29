//
//  LoginVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import UIKit

class LoginVC: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //IBActions
    @IBAction func loginTapped(_ sender: Any) {
        login()
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "registerVC") as! RegisterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //LoginErrors
    let noUser = "Cannot find user"
    let wrongPassword = "Wrong password"
    
    //Variables
    var logForm = LoginForm()
    var activityIndicator : UIActivityIndicatorView!
    var loggedUser = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isLoggedIn() {
            self.openMain()
        }
    }
    
    
    // This function shows the errors
    func showAlerts(_ error: UserError) {
        if (error == .noUser) {
            makeAlert(title: "Error", message: noUser)
        }
        if (error == .wrongPassword) {
            makeAlert(title: "Error", message: wrongPassword)
        }
    }
    
    
    //These functions will make the login
    func login() {
        logForm.Email = emailTF.text
        logForm.Password = passwordTF.text
    
        activityIndicator = UIActivityIndicatorView()
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        handleLogin(logForm, completion: { (str) in
            self.activityIndicator.stopAnimating()
        })
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "loggedIn")
    }
    
    //This functions navigates to the main screen
    func openMain() {
        let tabBar = self.storyboard?.instantiateViewController(identifier: "tabBarController") as! TabBarController
        tabBar.user = loggedUser
        self.navigationController?.pushViewController(tabBar, animated: true)
    }
    
    
    func handleLogin(_ logForm: LoginForm, completion:@escaping((String?) -> () )) {
        let loginRequest = UserRequest.init(endpoint: "login")
        
        loginRequest.loginUser(logForm ,completion: {result in
            switch result {
            case .success(let user):
                self.loggedUser = user
                DispatchQueue.main.async {
                    self.saveLoggedInState(user)
                    self.clearForm()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.openMain()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    self.showAlerts(error)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        })
    }
    
    func saveLoggedInState(_ user: User) {
        UserDefaults.standard.setValue(true, forKey: "loggedIn")
        UserDefaults.standard.setValue(user.token, forKey: "token")
        UserDefaults.standard.setValue(user.name, forKey: "name")
        UserDefaults.standard.setValue(user.email, forKey: "email")
        UserDefaults.standard.setValue(user.userId, forKey: "id")
        UserDefaults.standard.setValue(user.role, forKey: "role")
        UserDefaults.standard.synchronize()
    }
    
    func clearForm() {
        emailTF.text = ""
        passwordTF.text = ""
    }
}
