//
//  MasterViewController.swift
//  CData
//
//  Created by jhampac on 2/18/16.
//  Copyright © 2016 jhampac. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Commit]()
    var managedObjectContext: NSManagedObjectContext!
    
    // JSON related variables
    let dateFormatISO8601 = "yyyy-MM-dd'T'HH:mm:ss'Z'"


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        startCoreData()
        performSelectorInBackground("fetchCommits", withObject: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - VC Methods
    
    func fetchCommits()
    {
        let gitHubURL = NSURL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!
        
        if let data = NSData(contentsOfURL: gitHubURL)
        {
            let jsonCommits = JSON(data: data)
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                for jsonCommit in jsonCommitArray
                {
                    if let commit = NSEntityDescription.insertNewObjectForEntityForName("Commit", inManagedObjectContext: self.managedObjectContext) as? Commit
                    {
                        self.configureCommit(commit, usingJSON: jsonCommit)
                    }
                }
                
                self.saveContext()
            }
        }
    }
    
    func configureCommit(commit: Commit, usingJSON json: JSON)
    {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        
        // This means what format does this formater expect
        formatter.dateFormat = dateFormatISO8601
        
        commit.date = formatter.dateFromString(json["commit"]["committer"]["date"].stringValue) ?? NSDate()
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.message
        cell.detailTextLabel!.text = object.date.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - Core Data
    
    func startCoreData()
    {
        // Get NSURL path of momd file; schema
        let modelURL = NSBundle.mainBundle().URLForResource("CData", withExtension: "momd")!
        
        // Create a object model with the contents of that momd file
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // Create a persist coordinator using that object model
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        // Get a path to app sandbox sqlite file
        let url = getDocumentDirectory().URLByAppendingPathComponent("CData.sqlite")
        
        do
        {
            // Try to add that store type with coordinator
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
        }
        catch
        {
            print("cant save data")
            return
        }
    }
    
    func loadSavedData()
    {
        let fetch = NSFetchRequest(entityName: "Commit")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetch.sortDescriptors = [sort]
        
        do
        {
            if let commits = try managedObjectContext.executeFetchRequest(fetch) as? [Commit]
            {
                objects = commits
                tableView.reloadData()
            }
        }
        catch
        {
            print("Error")
        }
    }
    
    func saveContext()
    {
        if managedObjectContext.hasChanges
        {
            do
            {
                try managedObjectContext.save()
            }
            catch
            {
                print("An error occured while saving: \(error)")
            }
        }
    }
    
    func getDocumentDirectory() -> NSURL
    {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
}

