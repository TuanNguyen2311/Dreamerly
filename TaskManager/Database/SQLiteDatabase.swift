//
//  SqliteDatabase.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 10/09/2024.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

protocol SQLTable {
    static var createStatement: String { get }
}

class SQLiteDatabase {
    fileprivate var errorMessage: String {
      if let errorPointer = sqlite3_errmsg(dbPointer) {
        let errorMessage = String(cString: errorPointer)
        return errorMessage
      } else {
        return "No error message provided from sqlite."
      }
    }
    private let dbPointer: OpaquePointer?
    private init(dbPointer: OpaquePointer?) {
      self.dbPointer = dbPointer
    }
    deinit {
      sqlite3_close(dbPointer)
    }
  
    static func open(path: String) throws -> SQLiteDatabase {
      var db: OpaquePointer?
      if sqlite3_open(path, &db) == SQLITE_OK {
        return SQLiteDatabase(dbPointer: db)
      } else {
        defer {
          if db != nil {
            sqlite3_close(db)
          }
        }
        if let errorPointer = sqlite3_errmsg(db) {
          let message = String(cString: errorPointer)
          throw SQLiteError.OpenDatabase(message: message)
        } else {
          throw SQLiteError
            .OpenDatabase(message: "No error message provided from sqlite.")
        }
      }
    }
}

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
      var statement: OpaquePointer?
      guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil)
          == SQLITE_OK else {
        throw SQLiteError.Prepare(message: errorMessage)
      }
      return statement
     }
    
    func createTable(table: SQLTable.Type) throws {
      let createTableStatement = try prepareStatement(sql: table.createStatement)
      defer {
        sqlite3_finalize(createTableStatement)
      }
      guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
        throw SQLiteError.Step(message: errorMessage)
      }
      print("\(table) table created.")
    }
    
}
