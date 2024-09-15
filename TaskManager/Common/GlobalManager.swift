//
//  GlobalManager.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 15/09/2024.
//

import Foundation

class GlobalManager {
    static let shared = GlobalManager()
    private var projectList:Array<ProjectModel> = []
    var isReloadData = false
    
    private init (){
        initDatabase()
    }
    
    private func initDatabase(){//for testing
        projectList.removeAll()
        for i in 1...29{
            let project = ProjectModel(prjID:i,name: "Project_\(i)", status: initProjectStatusRandom(), dateFrom: "2024/09/\(randomFourDigitNumber(min:10,limit: 29))", dateTo: "2024/09/\(randomFourDigitNumber(min:10,limit: 29))")
            var taskList = project.taskList
            for j in 1...26 {
                let task = TaskModel(description: "Task_\(j)", status: initTaskStatusRandom())
                taskList.append(task)
            }
            project.taskList = taskList
            projectList.append(project)
        }
    }
    
    func getDatabaseByDate(dateFrom:String, status:ProjectStatus?=nil) -> (Array<ProjectModel>, Int, Int, Int, Int){
        var projectListByDate:Array<ProjectModel> = []
        var todoNum = 0
        var processingNum = 0
        var completedNum = 0
        var cancelNum = 0
        for project in getDatabase().0 {
            if dateFrom == project.dateFrom {
                if status == nil {
                    if project.status == .Todo {
                        todoNum += 1
                    } else if project.status == .Processing {
                        processingNum += 1
                    } else if project.status == .Completed {
                        completedNum += 1
                    } else {
                        cancelNum += 1
                    }
                    projectListByDate.append(project)
                } else {
                    if status == project.status {
                        if project.status == .Todo {
                            todoNum += 1
                        } else if project.status == .Processing {
                            processingNum += 1
                        } else if project.status == .Completed {
                            completedNum += 1
                        } else {
                            cancelNum += 1
                        }
                        projectListByDate.append(project)
                    }
                }
                
            }
        }
        return (projectListByDate, todoNum, processingNum, completedNum, cancelNum)
    }
    
    
    func resetDatabase(){
        initDatabase()
    }
    func getDatabase(status:ProjectStatus?=nil)->(Array<ProjectModel>, Int, Int, Int, Int){
        var todoNum = 0
        var processingNum = 0
        var completedNum = 0
        var cancelNum = 0
        var projectListFilter:Array<ProjectModel> = []
        
        for project in projectList {
            if status == nil {
                if project.status == .Todo {
                    todoNum += 1
                } else if project.status == .Processing {
                    processingNum += 1
                } else if project.status == .Completed {
                    completedNum += 1
                } else {
                    cancelNum += 1
                }
                projectListFilter.append(project)
            } else {
                if status == project.status {
                    if project.status == .Todo {
                        todoNum += 1
                    } else if project.status == .Processing {
                        processingNum += 1
                    } else if project.status == .Completed {
                        completedNum += 1
                    } else {
                        cancelNum += 1
                    }
                    projectListFilter.append(project)
                }
            }
        }
        return (projectListFilter, todoNum, processingNum, completedNum, cancelNum)
    }
    func deleteProject(projectDeleted:ProjectModel){
        let prjID = projectDeleted.prjID
        var indexDeleted = -1
        if projectList.count == 0 {
            return
        }
        for i in 0...projectList.count {
            let project = projectList[i]
            if project.prjID == projectDeleted.prjID {
                indexDeleted = i
                break
            }
        }
        if indexDeleted != -1 {
            projectList.remove(at: indexDeleted)
        }
        
    }
    func updateProject(projectUpdated:ProjectModel){
        let prjID = projectUpdated.prjID
        var indexUpdated = -1
        if projectList.count == 0 {
            return
        }
        for i in 0...projectList.count {
            let project = projectList[i]
            if project.prjID == projectUpdated.prjID {
                indexUpdated = i
                break
            }
        }
        if indexUpdated != -1 {
            projectList[indexUpdated] = projectUpdated
        }
        
    }
    func appendProject(project:ProjectModel){
        projectList.append(project)
    }
    
    
    
    
    
    
    
    
    
    func randomFourDigitNumber(min:Int=0,limit:Int) -> Int {
        return Int.random(in: min...limit)
    }
    
    func initProjectStatusRandom()->ProjectStatus {
        let randomInt = randomFourDigitNumber(limit: 3)
        switch randomInt {
        case 0:
            return .Todo
        case 1:
            return .Processing
        case 2:
            return .Completed
        case 3:
            return .Cancel
        default: return .Todo
        }
    }
    func initTaskStatusRandom()->TaskStatus {
        let isCompleted = Bool.random()
        if isCompleted {
            return .Completed
        } else {
            return .None
        }
        
    }
    
}
