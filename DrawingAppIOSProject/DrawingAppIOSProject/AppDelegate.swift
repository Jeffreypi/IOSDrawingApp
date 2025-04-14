//
//  AppDelegate.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-03-13.
//

import UIKit
import SQLite3
import PencilKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var databaseName : String? = "drawings.db"
    var databasePath : String?
    var image : [ImageData] = []
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentDir = documentPaths[0]
        databasePath = documentDir.appending("/" + databaseName!)
        
        
        
        return true
    }
    func viewImage(){
        
    }
    
    func getDrawingByID(_ id: Int) -> PKDrawing? {
        
        var db: OpaquePointer?

        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            let query = "SELECT DrawingData FROM DrawingsTable WHERE ID = ?;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(id))

                if sqlite3_step(statement) == SQLITE_ROW,
                   let blob = sqlite3_column_blob(statement, 0) {
                    let size = sqlite3_column_bytes(statement, 0)
                    let data = Data(bytes: blob, count: Int(size))
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return try? PKDrawing(data: data)
                }
            }

            sqlite3_finalize(statement)
            sqlite3_close(db)
        }

        return nil
    }

    
    func deleteDrawingFromDatabase(id: Int) {
        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            let deleteStatementString = "DELETE FROM DrawingsTable WHERE id = ?;"
            var deleteStatement: OpaquePointer?

            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(deleteStatement, 1, Int32(id))

                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("✅ Successfully deleted drawing with ID \(id)")
                } else {
                    print("Could not delete drawing.")
                }
            } else {
                print("DELETE statement could not be prepared.")
            }

            sqlite3_finalize(deleteStatement)
            sqlite3_close(db)
        }
    }

    
    func getImagesFromDatabase(){
        image.removeAll()
        
        let dbPath = databasePath
        var db: OpaquePointer?
        
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            let query = "SELECT ID, DrawingData, Timestamp, Title FROM DrawingsTable"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    if let blob = sqlite3_column_blob(statement, 1) {
                        let size = sqlite3_column_bytes(statement, 1)
                        let data = Data(bytes: blob, count: Int(size))
                        let timestamp = String(cString: sqlite3_column_text(statement, 2))
                        let title = String(cString: sqlite3_column_text(statement, 3))

                        let entry = ImageData()
                        entry.initWithData(theRow: id, theDrawing: data, theTimestamp: timestamp, theTitle: title)
                        image.append(entry)
                    }
                }
                sqlite3_finalize(statement)
            } else {
                print("Failed to prepare read query.")
            }
            sqlite3_close(db)
        } else {
            print("Failed to open database for reading.")
        }
    }
    
    func getDatabasePath() -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databasePath = documentsDirectory.appendingPathComponent("drawings.db").path
        
        return databasePath
    }
    
    func checkTableExists() {
        let dbPath = getDatabasePath()!
        
        var db: OpaquePointer?
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='DrawingsTable';"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_ROW {
                    print("Table DrawingsTable exists.")
                }else {
                    print("drawingstable does not exist. creating")
                    let createTableQuery = """
                    Create Table DrawingsTable( ID INTEGER PRIMARY KEY AUTOINCREMENT,
                    DrawingData BLOB,
                    Timestamp TEXT,
                    Title TEXT
                    );
                    """
                    if sqlite3_exec(db, createTableQuery, nil, nil, nil) == SQLITE_OK{
                        print("DrawingsTable created")
                        
                    }else{
                        print("Did not create DrawingsTable")
                    }
                
                    
                } 
                sqlite3_finalize(statement)
                sqlite3_close(db)
                
            }
            
        } else {
            print("Error opening database.")
        }
        
    }
    
    func saveDrawingToDatabase(drawing: PKDrawing, title: String) {
        guard let dbPath = (UIApplication.shared.delegate as? AppDelegate)?.databasePath else { return }

        var db: OpaquePointer?
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            let insertStatementString = "INSERT INTO DrawingsTable (DrawingData, Timestamp, Title) VALUES (?, ?, ?);"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, insertStatementString, -1, &statement, nil) == SQLITE_OK {
                let drawingData = drawing.dataRepresentation() as NSData
                let timestamp = String(describing: Date())
               // let title = String()

                sqlite3_bind_blob(statement, 1, drawingData.bytes, Int32(drawingData.length), nil)
                sqlite3_bind_text(statement, 2, (timestamp as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (title as NSString).utf8String, -1, nil)

                if sqlite3_step(statement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("Drawing saved successfully \(rowID).")
                } else {
                    print("Failed to save drawing.")
                    
                }

                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        } else {
            print("Could not open database.")
        }
    }

    
   
    
    func checkAndCreateDatabase(){
        var success = false
        let fileManager = FileManager.default
        
        success = fileManager.fileExists(atPath: databasePath!)
        
        if success
        {
            return
        }
        
        let databasePathFromApp = Bundle.main.resourcePath?.appending("/" + databaseName!)
        
        try? fileManager.copyItem(atPath: databasePathFromApp!, toPath: databasePath!)
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

