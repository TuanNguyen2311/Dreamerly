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
    
    func updateStatus(){
        guard let from = dateFrom.toDate(Constants.dateFormatted_1),
                  let to = dateFrom.toDate(Constants.dateFormatted_1) else {
                return // Trả về 0 nếu có lỗi định dạng
            }
        
        let percent = getPercentProcessing()
        let today = Date()
        if percent == 0 {
            if today >= from && today <= to {
                status = .Processing
            } else if today > to {
                status = .Cancel
            } else if today < from {
                status = .Todo
            }
        } else if percent < 100 {
            if today >= from && today <= to {
                status = .Processing
            } else if today > to {
                status = .Cancel
            } else if today < from {
                status = .Processing
            }
        } else {
            status = .Completed
        }
        
    }
    
    func getPercentProcessing()->Int {
        if taskList.count == 0 {
            return 0
        } else {
            let countComplete = taskList.filter { $0.status == .Completed }.count
            print("countComplete:\(countComplete)__taskList:\(taskList.count)")
            let result = Double(countComplete) / Double(taskList.count)

            let formattedResult = Double(String(format: "%.2f", result)) ?? 0

            return Int(formattedResult*100)
        }
        
    }
    
}
