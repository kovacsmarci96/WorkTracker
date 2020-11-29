//
//  UIViewControllerExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import UIKit

extension UIViewController {
    @IBAction func unwind(_ segie: UIStoryboardSegue) {}
    
    func hideKeyboard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style:.default , handler: nil))
        self.present(alert, animated: true)
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
