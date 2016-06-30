//
//  MusicFile.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/13/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation
import CoreData


class MusicFile: NSManagedObject {

    class func musicFileWithLocalURL(music: Music, inManagedObjectContext context: NSManagedObjectContext) -> MusicFile?
    {
        let request = NSFetchRequest(entityName: "MusicFile")
        request.predicate = NSPredicate(format: "id = %@", music.id!)
        if let musicFile = (try? context.executeFetchRequest(request))?.first as? MusicFile {
            return musicFile
        } else if let musicFile = NSEntityDescription.insertNewObjectForEntityForName("MusicFile", inManagedObjectContext: context) as? MusicFile{
            musicFile.id = music.id
            musicFile.name = music.name
            return musicFile
        }
        return nil
    }
    
}
