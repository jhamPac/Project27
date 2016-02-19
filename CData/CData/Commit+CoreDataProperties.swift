//
//  Commit+CoreDataProperties.swift
//  CData
//
//  Created by jhampac on 2/19/16.
//  Copyright © 2016 jhampac. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Commit
{
    @NSManaged var date: NSDate
    @NSManaged var message: String
    @NSManaged var sha: String
    @NSManaged var url: String
}
