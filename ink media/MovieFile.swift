//
//  MovieFile.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/16/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation
import CoreData


class MovieFile: NSManagedObject {

    class func movieFileWithLocalURL(fileName: String, fileID: String, inManagedObjectContext context: NSManagedObjectContext) -> MovieFile?
    {
        let request = NSFetchRequest(entityName: "MovieFile")
        request.predicate = NSPredicate(format: "id = %@", fileID)
        if let movieFile = (try? context.executeFetchRequest(request))?.first as? MovieFile {
            return movieFile
        } else if let movieFile = NSEntityDescription.insertNewObjectForEntityForName("MovieFile", inManagedObjectContext: context) as? MovieFile{
            movieFile.id = fileID
            movieFile.name = fileName
            return movieFile
        }
        return nil
    }
}
