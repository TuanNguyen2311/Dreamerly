//
//  ProjectViewCell.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 14/09/2024.
//

import UIKit

class ProjectViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(_ projectModel: ProjectModel){
        nameLabel.text = projectModel.name
        progressView.progress = Float(projectModel.getPercentProcessing())
        progressLabel.text = "\(projectModel.getPercentProcessing()*100) %"
        deadlineLabel.text = projectModel.dateTo
    }
    
}
