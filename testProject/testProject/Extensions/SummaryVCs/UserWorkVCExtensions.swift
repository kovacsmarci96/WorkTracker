//
//  UserWorkVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import Foundation
import UIKit

extension UserWorkVC: UIPickerViewDelegate {
}

extension UserWorkVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(hours[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        workHourTF.text = String(hours[row])
        workHourTF.resignFirstResponder()
        commentTF.resignFirstResponder()
    }
}

extension UserWorkVC {
    
    
    // MARK: - API Request
    
    func updateWork(_ work: WorkAdd) {
        let workRequest = WorkRequest.init(projectId: project.id!, taskId: task.id!, endpoint: "workItems/\(work.id!)")
        
        workRequest.updateWork(user.token!, work, completion: {result in
            switch result {
            case .success(let work):
                print("Work: \(work.comment!) updated")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    // MARK: - These functions updates a work
    
    @objc func editTapped() {
        editing()
    }
    
    @objc func doneEditing() {
        dateTF.isEnabled = false
        commentTF.isEnabled = false
        workHourTF.isEnabled = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        if(dateTF.text == work.createdDate && commentTF.text == work.comment && Double(workHourTF.text!) == work.time) {
            makeAlert(title: "Error", message: "Nothing has changed.")
        } else {
            let updatedWorkAdd = WorkAdd()
            updatedWorkAdd.comment = commentTF.text
            updatedWorkAdd.createdBy = work.createdBy
            updatedWorkAdd.date = dateTF.text
            updatedWorkAdd.id = work.id
            updatedWorkAdd.taskId = work.taskId
            updatedWorkAdd.time = Double(workHourTF.text!)
            
            let updatedWork = Work()
            updatedWork.comment = updatedWorkAdd.comment
            updatedWork.createdBy = updatedWorkAdd.createdBy
            updatedWork.createdDate = updatedWorkAdd.date
            updatedWork.id = updatedWorkAdd.id
            updatedWork.taskId = updatedWorkAdd.taskId
            updatedWork.time = updatedWorkAdd.time
            
            updateWork(updatedWorkAdd)
            delegate?.updateWork(updatedWork, task)
            updateSummaryDelegate?.updateSummaryWork(work)
            makeAlert(title: "Success", message: "Work has been updated")
        }
        workHourTF.borderStyle = .none
        commentTF.borderStyle = .none
        dateTF.borderStyle = .none
    }
    
    func editing() {
        dateTF.isEnabled = true
        commentTF.isEnabled = true
        workHourTF.isEnabled = true
        workHourTF.borderStyle = .roundedRect
        commentTF.borderStyle = .roundedRect
        dateTF.borderStyle = .roundedRect
        dateTF.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    }
    
    // MARK: - This function checks the form validity
    
    func checkForm() -> Bool {
        if workHourTF.text == "" {
            makeAlert(title: "Error", message: "Please add a work hour.")
            return false
        }
        if dateTF.text == "" {
            makeAlert(title: "Error", message: "Please add a date.")
            return false
        }
        if commentTF.text == "" {
            makeAlert(title: "Error", message: "Please add a comment.")
            return false
        }
        return true
    }
    
    // MARK: - Create the datePicker
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let today = Date()
        datePicker.maximumDate = today
        
        dateTF.inputAccessoryView = toolbar
        dateTF.inputView = datePicker
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTF.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
}
