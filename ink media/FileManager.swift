//
//  FileManager.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/13/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class FileManager: NSObject {
    
    
    
    class func pathOfDocumentDirectory() -> NSURL
    {
        let fileManager = NSFileManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    class func pathOfCachesDirectory() -> NSURL
    {
        let fileManager = NSFileManager()
        
        let urls = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    class func createDirectoryOfName(name: String?) -> NSURL?
    {
        if( name != nil)
        {
            let documentDirectory = self.pathOfDocumentDirectory()
            let pathOfNewDirectory = documentDirectory.URLByAppendingPathComponent(name!)
            let fileManager = NSFileManager()
            
            do{
                try fileManager.createDirectoryAtURL(pathOfNewDirectory, withIntermediateDirectories: true, attributes: nil)
                return pathOfNewDirectory
            }
            catch
            {
                print("Create directory failed")
                return nil
            }
        }
        return nil
    }
    
    class func getDirectoryPath(directoryName: String?) -> NSURL?
    {
        if directoryName != nil
        {
            let fileManager = NSFileManager()
            let url =  pathOfDocumentDirectory().URLByAppendingPathComponent(directoryName!)
            print(url)
            var isDirectory = ObjCBool(true)
            if fileManager.fileExistsAtPath(url.absoluteString, isDirectory: &isDirectory) {
                if isDirectory {
                    return url
                }
            }
        }
        return nil
    }
    
    class func getFileName(url: NSURL?) -> String?
    {
        return url?.lastPathComponent
    }
    
    class func makePersistentURL(fileName: String?, directoryName: String?) -> NSURL?
    {
        if((fileName != nil) && (directoryName != nil))
        {
            var directoryURL = getDirectoryPath(directoryName)
            if directoryURL == nil {
                directoryURL = createDirectoryOfName(directoryName)
            }
            return directoryURL!.URLByAppendingPathComponent(fileName!)
        }
        return nil
    }
    
    class func moveTempFileToDocumentDirectory(fromURL: NSURL?, toURL: NSURL?) -> Bool
    {
        if((fromURL != nil) && (toURL != nil))
        {
            let fileManager = NSFileManager()
            do{
                try fileManager.moveItemAtURL(fromURL!, toURL: toURL!)
                return true
            }
            catch let error
            {
                print("Move temp file failed, error: \(error)")
                return false
            }
        }
        return false
    }
    
    class func copyTempFileToDocumentDirectory(fromURL: NSURL?, toURL: NSURL?) -> Bool
    {
        if((fromURL != nil) && (toURL != nil))
        {
            let fileManager = NSFileManager()
            do{
                try fileManager.copyItemAtURL(fromURL!, toURL: toURL!)
                return true
            }
            catch let error
            {
                print("Move temp file failed, error: \(error)")
                return false
            }
        }
        return false
    }
    
    class func deleteFileInDocumentDirectory(fileName: String?) -> Bool
    {
        if fileName != nil {
            let url = pathOfDocumentDirectory().URLByAppendingPathComponent(fileName!)
            let fileManager = NSFileManager()
            do {
                try fileManager.removeItemAtURL(url)
                return true
            }
            catch
            {
                print("Delete file failed")
                return  false
            }
        }
        return false
    }
    
    class func deleteFileOfURL(fileURL: NSURL?) -> Bool
    {
        if let url = fileURL {
            let fileManager = NSFileManager()
            do {
                try fileManager.removeItemAtURL(url)
                return true
            }
            catch
            {
                print("Delete file failed")
                return  false
            }
        }
        return false
    }
    
    class func getFileFromDocumentDirectory(fileName: String?) -> NSData?
    {
        if fileName != nil {
            let url = pathOfDocumentDirectory().URLByAppendingPathComponent(fileName!)
            let fileManager = NSFileManager()
            return fileManager.contentsAtPath(url.absoluteString)
        }
        return nil
    }
}