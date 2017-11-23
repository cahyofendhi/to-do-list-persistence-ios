//
//  MyToDo.swift
//  To-do
//
//  Created by DOT Indonesia on 11/23/17.
//  Copyright © 2017 bcr. All rights reserved.
//

import Foundation

class ToDoItem: NSObject, NSCoding {
    
    var title: String
    var done: Bool
    
    public init(title: String){
        self.title  = title
        self.done   = false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.done, forKey: "done")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = title
        } else {
            return nil
        }
        
        if aDecoder.containsValue(forKey: "done") {
            self.done = aDecoder.decodeBool(forKey: "done")
        } else {
            return nil
        }
    }
    
    
}

extension ToDoItem {
    
    public class func getMockData() -> [ToDoItem]{
        return [
            ToDoItem(title: "Milk"),
            ToDoItem(title: "Chocolate"),
            ToDoItem(title: "Ligh bulp"),
            ToDoItem(title: "Dog Food")
        ]
    }
    
}

// but only if it is an array of ToDoItem objects.
extension Collection where Iterator.Element == ToDoItem
{
    // Builds the persistence URL. This is a location inside
    // the "Application Support" directory for the App.
    private static func persistencePath() -> URL?
    {
        let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return url?.appendingPathComponent("todoitems.bin")
    }
    
    // Write the array to persistence
    func writeToPersistence() throws
    {
        if let url = Self.persistencePath(), let array = self as? NSArray
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to: url)
        }
        else
        {
            throw NSError(domain: "bcr.To-do.ToDoModel", code: 10, userInfo: nil)
        }
    }
    
    // Read the array from persistence
    static func readFromPersistence() throws -> [ToDoItem]
    {
        if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ToDoItem]
            {
                return array
            }
            else
            {
                throw NSError(domain: "bcr.To-do.ToDoModel", code: 11, userInfo: nil)
            }
        }
        else
        {
            throw NSError(domain: "bcr.To-do.ToDoModel", code: 12, userInfo: nil)
        }
    }
}


