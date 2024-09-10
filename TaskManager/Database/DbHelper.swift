//
//  DbHelper.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 10/09/2024.
//

import Foundation
import SQLite3


class DbHelper {
    fileprivate let dbVersion = 0
    static let shared = DbHelper()//the public dbHelper variable to use anywhere in source
    let fileURLDataBase = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TaskManager.sqlite")
    fileprivate var sqlite: SQLiteDatabase?
    
    func OpenDatabase(){
        do {
            sqlite = try SQLiteDatabase.open(path: fileURLDataBase.path)
            createTable()
            detectDatabaseVersion()
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(_) {
            print("Unable to open database.")
        } catch {
            print("Unable to open database.")
        }
    }
    
    func detectDatabaseVersion(){
        let currentDBVersion = UserDefaults.standard.integer(forKey: "dbVersion")
        
    }
    
    func createTable(){
        do {
            try sqlite?.createTable(table: TaskManager.self)
            try sqlite?.createTable(table: ProjectManager.self)
        } catch {}
    }
}
