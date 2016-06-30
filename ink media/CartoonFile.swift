//
//  CartoonFile.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/18/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation
import CoreData


class CartoonFile: NSManagedObject {

    class func cartoonFileWithLocalURL(fileName: String, fileID: String, inManagedObjectContext context: NSManagedObjectContext) -> CartoonFile?
    {
        let request = NSFetchRequest(entityName: "CartoonFile")
        request.predicate = NSPredicate(format: "id = %@", fileID)
        if let cartoonFile = (try? context.executeFetchRequest(request))?.first as? CartoonFile {
            return cartoonFile
        } else if let cartoonFile = NSEntityDescription.insertNewObjectForEntityForName("CartoonFile", inManagedObjectContext: context) as? CartoonFile{
            cartoonFile.id = fileID
            cartoonFile.name = fileName
            return cartoonFile
        }
        return nil
    }
}
