//
//  TaskCell.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var descrLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
