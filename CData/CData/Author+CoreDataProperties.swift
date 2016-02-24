//
//  Author+CoreDataProperties.swift
//  CData
//
//  Created by jhampac on 2/24/16.
//  Copyright © 2016 jhampac. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Author {

    @NSManaged var name: String
    @NSManaged var email: String
    @NSManaged var commits: NSSet

}
