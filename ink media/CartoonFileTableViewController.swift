//
//  CartoonFileTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/19/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class CartoonFileTableViewController: CoreDataTableViewController {

    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "动漫播放器"
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: UIImage(named: "guidepage"))
        let blur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.tableView.bounds
        self.tableView.backgroundView!.insertSubview(blurView, atIndex: 0)

        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateUI()
    {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "CartoonFile")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CartoonFileCell", forIndexPath: indexPath)
        
        if let cartoonFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? CartoonFile {
            var fileName: String?
            var fileID: String?
            cartoonFile.managedObjectContext?.performBlockAndWait {
                fileName = cartoonFile.name
                fileID = cartoonFile.id
            }
            cell.textLabel?.text = fileName
            cell.detailTextLabel?.text = fileID
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cartoonFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? CartoonFile
        let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent((cartoonFile?.name!)! + (cartoonFile?.id!)! + ".mp4")
        let tvPlayerVC = TVPlayerController()
        tvPlayerVC.player = AVPlayer(URL: fileURL)
        self.navigationController?.presentViewController(tvPlayerVC, animated: true, completion: nil)
}
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            if let cartoonFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? CartoonFile
            {
                let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent((cartoonFile.name!) + (cartoonFile.id!) + ".mp4")
                if (FileManager.deleteFileOfURL(fileURL))
                {
                    managedObjectContext?.deleteObject(cartoonFile)
                } else {
                    errorAlert("Delete file failed")
                }
            }
        }
    }
    
    func errorAlert(errorMessage: String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "Cartoon", message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
