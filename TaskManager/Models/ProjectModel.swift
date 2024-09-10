//
//  ProjectModel.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 10/09/2024.
//

import Foundation

enum ProjectStatus: String {
    case Todo, Processing, Completed, Cancel
}

public class ProjectModel {
    var prjID:Int?
    var name:String?
    var status:ProjectStatus?
    var deadline:String?
    var taskList:Array<TaskModel>?
    
    init(prjID: Int? = -1, name: String, status: ProjectStatus? = ProjectStatus.Todo, deadline: String, taskList: Array<TaskModel>? = nil) {
        self.prjID = prjID
        self.name = name
        self.status = status
        self.deadline = deadline
        self.taskList = taskList
    }
    
    func getPercentProcessing()->Double {
        guard let taskList = taskList else {
            return 0
        }
        let countComplete = taskList.filter { $0.status == .Completed }.count
        return Double(countComplete) / Double(taskList.count)
    }
    
}
