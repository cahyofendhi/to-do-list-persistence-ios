//
//  ViewController.swift
//  To-do
//
//  Created by DOT Indonesia on 11/23/17.
//  Copyright © 2017 bcr. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

//    private var todoItem    = ToDoItem.getMockData()
    private var todoItem = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title  = "To-Do-List"
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(ViewController.didTapAdditemButton(_:)))
        
        self.setupDataPersistence()
    }

    func setupDataPersistence() {
        // Setup a notification to let us know when the app is about to close,
        // and that we should store the user items to persistence. This will call the
        // applicationDidEnterBackground() function in this class
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        do
        {
            // Try to load from persistence
            self.todoItem = try [ToDoItem].readFromPersistence()
        }
        catch let error as NSError
        {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
            {
                NSLog("No persistence file found, not necesserially an error...")
            }
            else
            {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load the to-do items!",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        if indexPath.row < todoItem.count {
            let item    = todoItem[indexPath.row]
            cell.textLabel?.text    = item.title
            
            let accessory: UITableViewCellAccessoryType = item.done ? .checkmark : .none
            cell.accessoryType  = accessory
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < todoItem.count{
            let item    = todoItem[indexPath.row]
            item.done   = !item.done
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < todoItem.count {
            todoItem.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    @objc func didTapAdditemButton(_ sender:UIBarButtonItem)  {
        let alert   = UIAlertController(
            title: "New to-do item",
            message: "Insert the title of the new to-do item",
            preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { (_) in
                                        
            if let title = alert.textFields?[0].text {
                self.addNewToDoItem(title: title)
            }
                                        
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewToDoItem(title: String){
        let newIndex    = todoItem.count
        todoItem.append(ToDoItem(title: title))
        let newIndexPath = IndexPath(item: newIndex, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .top)
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification: NSNotification)
    {
        do
        {
           try todoItem.writeToPersistence()
        }
        catch let error
        {
            NSLog("Error writing to persistence: \(error)")
        }
    }
    
}

