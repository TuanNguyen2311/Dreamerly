//
//  TaskTableViewCell.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 15/09/2024.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var taskContentLabel: UILabel!
    var taskData:TaskModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        return
    }
    
    func commonInit(_ task:TaskModel){
        taskData = task
        taskContentLabel.text = taskData!.description
        displayStatus()
        
    }
    
    func displayStatus(){
        let status = taskData!.status
        statusView.backgroundColor = (status == .None) ? Constants.noneStatusColor:Constants.completedStatusColor
    }
    
    
    @IBAction func checkedAC(_ sender: Any) {
        let status = taskData!.status
        if status == .None {
            taskData?.status = .Completed
        } else {
            taskData?.status = .None
        }
        displayStatus()
    }
    
}
