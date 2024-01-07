//
//  HistoryDBHelper.swift
//  wa.me
//
//  Created by Danial Fajar on 06/01/2024.
//

import Foundation
import SQLite3

extension DBHelper {
    func createHistoryTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY AUTOINCREMENT, phoneNumber TEXT, message TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            switch sqlite3_step(createTableStatement) {
            case SQLITE_DONE:
                #if DEBUG
                print("History table created.")
                #endif
                break
            default:
                #if DEBUG
                print("History table could not be created.")
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
    
    
    func insertHistory(phoneNumber: String, message: String) {
        let data = readHistory()
        
        guard data?.filter({$0.phoneNumber == "\(phoneNumber)"}).count == 0 else {
            updateHistory(phoneNumber: phoneNumber, message: message)
            return
        }
        
        let insertStatementString = "INSERT INTO History(id, phoneNumber, message) VALUES (?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 2, (phoneNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (message as NSString).utf8String, -1, nil)
            
            
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
    
    func updateHistory(phoneNumber: String, message: String) {
        let updateStatementString = "UPDATE History SET message = '\(message)' WHERE phoneNumber = \(phoneNumber);"
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
    
    func readHistory() -> [HistoryDataModel]? {
        let queryStatementString = "SELECT * FROM History;"
        var queryStatement: OpaquePointer? = nil
        var psns: [HistoryDataModel] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(sqlite3_column_int(queryStatement, 0))
                let phoneNumber = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let message = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                psns.append(HistoryDataModel(id: id, phoneNumber: phoneNumber, message: message))
                #if DEBUG
                print("Query Result:")
                print("\(id) | \(phoneNumber) | \(message)")
                #endif
            }
        } else {
            #if DEBUG
            print("SELECT statement could not be prepared")
            #endif
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
    func deleteHistoryData(phoneNumber: String) -> [HistoryDataModel]? {
        let deleteStatementStirng = "DELETE FROM History WHERE phoneNumber = \(phoneNumber);"
        var deleteStatement: OpaquePointer? = nil
        var psns: [HistoryDataModel]?
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            switch sqlite3_step(deleteStatement) {
            case SQLITE_DONE:
                psns = readHistory()
                #if DEBUG
                print("Successfully delete row.")
                #endif
                break
            default:
                #if DEBUG
                print("Could not delete row.")
                #endif
                break
            }
        } else {
            #if DEBUG
            print("Delete row statement could not be prepared")
            #endif
        }
        sqlite3_finalize(deleteStatement)
        return psns
    }
    
    func deleteAllHistroyData() {
        let deleteStatementStirng = "DROP TABLE IF EXISTS History;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            switch sqlite3_step(deleteStatement) {
            case SQLITE_DONE:
                createHistoryTable()
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
