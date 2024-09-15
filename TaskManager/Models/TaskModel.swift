//
//  TaskModel.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 10/09/2024.
//

import Foundation

enum TaskStatus: String {
    case None, Completed
}


public class TaskModel {
    var taskID:Int = -1
    var description:String = ""
    var status:TaskStatus = .None
    
    init(taskID: Int = -1, description: String, status: TaskStatus = TaskStatus.None) {
        self.taskID = taskID
        self.description = description
        self.status = status
    }
}
