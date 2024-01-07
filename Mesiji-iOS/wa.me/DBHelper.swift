//
//  DBHelper.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import Foundation
import SQLite3

class DBHelper {
    
    init() {
        db = openDatabase()
        createCustomDataTable()
        createHistoryTable()
    }

    let dbPath: String = "mesiji.sqlite"
    var db: OpaquePointer?

    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            #if DEBUG
            print("error opening database")
            #endif
            sqlite3_close(db)
            
            return nil
        }
        
        return db
    }
    
    func createCustomDataTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS CustomData(id INTEGER PRIMARY KEY AUTOINCREMENT, fields TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            switch sqlite3_step(createTableStatement) {
            case SQLITE_DONE:
                #if DEBUG
                print("CustomData table created.")
                #endif
                break
            default:
                #if DEBUG
                print("CustomData table could not be created.")
                #endif
                break
            }
        } else {
            #if DEBUG
            print("CREATE TABLE statement could not be prepared.")
            #endif
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    func insert(fields: String) {
        let data = readCustomField()
        
        guard data?.fields?.count ?? 0 == 0 else {
            update(fields: fields)
            return
        }
        
        let insertStatementString = "INSERT INTO CustomData(id, fields) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 2, (fields as NSString).utf8String, -1, nil)
            
            switch sqlite3_step(insertStatement) {
            case SQLITE_DONE:
                #if DEBUG
                print("Successfully inserted row.")
                #endif
                break
            default:
                #if DEBUG
                print("Could not insert row.")
                #endif
                break
            }
        } else {
            #if DEBUG
            print("INSERT statement could not be prepared.")
            #endif
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func update(fields: String) {
        let updateStatementString = "UPDATE CustomData SET fields = '\(fields)' WHERE id = 1;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func readCustomField() -> CustomDataModel? {
        let queryStatementString = "SELECT * FROM CustomData;"
        var queryStatement: OpaquePointer? = nil
        var psns: [CustomField] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let fields = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                psns = fields.decodeJSONData() ?? []
                #if DEBUG
                print("Query Result:")
                print("\(fields)")
                #endif
            }
        } else {
            #if DEBUG
            print("SELECT statement could not be prepared")
            #endif
        }
        sqlite3_finalize(queryStatement)
        return CustomDataModel(fields: psns)
    }
    
    func deleteAllData() {
        let deleteStatementStirng = "DROP TABLE IF EXISTS CustomData;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            switch sqlite3_step(deleteStatement) {
            case SQLITE_DONE:
                createCustomDataTable()
                #if DEBUG
                print("Successfully drop table.")
                #endif
                break
            default:
                #if DEBUG
                print("Could not drop table.")
                #endif
                break
            }
        } else {
            #if DEBUG
            print("DROP statement could not be prepared")
            #endif
        }
        sqlite3_finalize(deleteStatement)
    }
}
