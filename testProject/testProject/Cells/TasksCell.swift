//
//  TasksCell.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 28..
//

import UIKit

class TasksCell: UITableViewCell {
    @IBOutlet weak var taskNameTF: UILabel!
    @IBOutlet weak var taskDescrTF: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
