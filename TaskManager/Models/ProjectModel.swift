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

enum ProjectPriority: String {
    case Low, Medium, High, Urgent
}

public class ProjectModel {
    var prjID:Int = -1
    var name:String = ""
    var status:ProjectStatus = .Todo
    var dateFrom:String = ""
    var dateTo:String = ""
    var priority:ProjectPriority = .Low
    var taskList:Array<TaskModel> = []
    
    init(prjID: Int = -1, name: String, status: ProjectStatus = .Todo, dateFrom: String = Date().toString(Constants.dateFormatted_1), dateTo: String = Date().toString(Constants.dateFormatted_1), priority: ProjectPriority = .Low, taskList: Array<TaskModel> = []) {
        self.prjID = prjID
        self.name = name
        self.status = status
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.priority = priority
        self.taskList = taskList
    }
    
    func getPercentProcessing()->Double {
        if taskList.count == 0 {
            return 0
        } else {
            let countComplete = taskList.filter { $0.status == .Completed }.count
            return Double(countComplete) / Double(taskList.count)
        }
        
    }
    
}
