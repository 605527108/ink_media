//
//  MusicFileTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/13/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class MusicFileTableViewController: CoreDataTableViewController {
    
    var musicPlayingQueue = [Music]()
    
    var numOfMusicFile: Int?
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "音乐播放器"
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: UIImage(named: "guidepage"))
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.tableView.bounds
        self.tableView.backgroundView!.insertSubview(blurView, atIndex: 0)
        
        updateUI()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func updateUI()
    {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "MusicFile")
            request.predicate = nil
            request.sortDescriptors = [NSSortDescriptor(
                key: "id",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        else
        {
            fetchedResultsController = nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicFileCell", forIndexPath: indexPath)
        
        if let musicFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? MusicFile {
            var fileName: String?
            var fileID: String?
            musicFile.managedObjectContext?.performBlockAndWait {
                fileName = musicFile.name
                fileID = musicFile.id
            }
            cell.textLabel?.text = fileName
            cell.detailTextLabel?.text = fileID
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sendPlayMessageToPlayer(indexPath)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            if let musicFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? MusicFile
            {
                let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent((musicFile.name!) + (musicFile.id!) + ".mp3")
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMuiscFile", object: nil, userInfo: ["signal":"delete"])
                if (FileManager.deleteFileOfURL(fileURL))
                {
                    managedObjectContext?.deleteObject(musicFile)
                } else {
                    errorAlert("Delete file failed")
                }
            }
        }
    }
    
    func errorAlert(errorMessage: String)
    {
        dispatch_async(dispatch_get_main_queue()) { 
            let alertController = UIAlertController(title: "Music", message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func sendPlayMessageToPlayer(startAtIndexPath: NSIndexPath)
    {
        musicPlayingQueue.removeAll()
        numOfMusicFile = fetchedResultsController?.sections![startAtIndexPath.section].numberOfObjects
        for index in 0...(numOfMusicFile!-1)
        {
            let iterator = NSIndexPath(forRow: index, inSection: startAtIndexPath.section)
            let musicFile = fetchedResultsController?.objectAtIndexPath(iterator) as? MusicFile
            let music = Music(name: (musicFile?.name!)!, id: (musicFile?.id!)!)
            musicPlayingQueue.append(music)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMuiscFile", object: nil, userInfo: ["musicPlayingQueue":musicPlayingQueue,"signal":"play","startAtIndexPath":startAtIndexPath.row])
    }
}

