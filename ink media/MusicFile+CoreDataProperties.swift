//
//  MusicFile+CoreDataProperties.swift
//  ink media
//
//  Created by Syn Ceokhou on 6/21/16.
//  Copyright © 2016 iNankai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MusicFile {

    @NSManaged var id: String?
    @NSManaged var name: String?

}
