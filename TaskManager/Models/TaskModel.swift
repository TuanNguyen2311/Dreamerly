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
enum TaskPriority: String {
    case Low, Medium, Hight, Urgent
}

public class TaskModel {
    var taskID:Int?
    var description:String?
    var status:TaskStatus?
    var priority:TaskPriority?
    
    init(taskID: Int? = -1, description: String, status: TaskStatus? = TaskStatus.None, priority: TaskPriority? = TaskPriority.Low) {
        self.taskID = taskID
        self.description = description
        self.status = status
        self.priority = priority
    }
}
