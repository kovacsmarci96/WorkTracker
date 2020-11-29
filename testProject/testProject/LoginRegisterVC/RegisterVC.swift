//
//  RegisterVC.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import UIKit

class RegisterVC: UIViewController {
    
    // IBOutlets:
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailReTF: UITextField!
    @IBOutlet weak var passwordReTF: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    //IBActions
    @IBAction func registerTapped(_ sender: Any) {
        register()
    }
    
    //Error strings
    let emptyEmail = "Email and password cannot be empty."
    let nameError = "Name cannot be empty."
    let passwordNotMatch = "Password and confirmation doesnt match."
    let emailNotMatch = "Email and confirmation doesnt match."
    let shortPassword = "Passwords must be at least 6 characters."
    let digitPassword = "Passwords must have at least one digit ('0'-'9')."
    let upperCase = "Passwords must have at least one uppercase ('A'-'Z')."
    let invalidEmail = "Email is invalid"
    let usedEmail = "Email already in use."

    //Variables
    var activityIndicator : UIActivityIndicatorView!
    let regForm = RegForm()
    var loggedUser = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // This functions shows error alerts
    func showAlerts(_ error: UserError) {
        if (error == .emailPasswordEmpty) {
            makeAlert(title: "Error", message: emptyEmail)
        }
        if (error == .nameEmpty) {
            makeAlert(title: "Error", message: nameError)
        }
        if (error == .passwordNotMatch) {
            makeAlert(title: "Error", message: passwordNotMatch)
        }
        if (error == .emailNotMatch) {
            makeAlert(title: "Error", message: emailNotMatch)
        }
        if (error == .shortPassword) {
            makeAlert(title: "Error", message: shortPassword)
        }
        if (error == .digitPassword) {
            makeAlert(title: "Error", message: digitPassword)
        }
        if (error == .upperCase) {
            makeAlert(title: "Error", message: upperCase)
        }
        if (error == .invalidEmail) {
            makeAlert(title: "Error", message: invalidEmail)
        }
        if (error == .emailAlreadyInUse) {
            makeAlert(title: "Error", message: usedEmail)
        }
    }
    
    
    // This function navigates to the main screen
    func openMain(_ user: User) {
        let tabBar = self.storyboard?.instantiateViewController(identifier: "tabBarController") as! TabBarController
        tabBar.user = user
        tabBar.register = true
        self.navigationController?.pushViewController(tabBar, animated: true)
    }
    
    
    // These functions does the registration and login
    func register() {
        regForm.Name = nameTF.text
        regForm.Email = emailTF.text
        regForm.EmailRe = emailReTF.text
        regForm.Password = passwordTF.text
        regForm.PasswordRe = passwordReTF.text
    
        activityIndicator = UIActivityIndicatorView()
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        handleRegister(regForm, completion: { (str) in
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.login()
            self.clearForm()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    func handleRegister(_ form: RegForm, completion:@escaping((String?) -> () )){
        
        let userRequest = UserRequest.init(endpoint: "register")
        
        userRequest.registerUser(form, completion: {result in
            switch result {
            case .success(let form):
                print("\(form.Name!) registered")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlerts(error)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        })
    }
    
    func login() {
        let logForm = LoginForm()
        logForm.Email = emailTF.text!
        logForm.Password = passwordTF.text
        
        handleLogin(logForm, completion: { (str) in
        })
    }
    
    func handleLogin(_ logForm: LoginForm, completion:@escaping((String?) -> () )) {
        let loginRequest = UserRequest.init(endpoint: "login")
        
        loginRequest.loginUser(logForm ,completion: {result in
            switch result {
            case .success(let user):
                self.loggedUser = user
                DispatchQueue.main.async {
                    self.saveLoggedInState(user)
                    self.openMain(user)
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.clearForm()
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
        nameTF.text = ""
        emailTF.text = ""
        passwordTF.text = ""
        emailReTF.text = ""
        passwordReTF.text = ""
    }
    
    

}
