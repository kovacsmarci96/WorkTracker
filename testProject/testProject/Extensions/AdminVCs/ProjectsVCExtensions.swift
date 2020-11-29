//
//  ProjectsVCExtensions.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation
import UIKit

extension ProjectsVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        AddProjectViewController(presentedViewController: presented, presenting: presenting)
    }
}

extension ProjectsVC: AddProjectDelegate {
    func viewWillDismiss() {
        self.viewWillAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.reloadData()
        }
    }

}
