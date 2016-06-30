//
//  MovieFileTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/18/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class MovieFileTableViewController: CoreDataTableViewController,UIDocumentInteractionControllerDelegate {
    
    var documentController: UIDocumentInteractionController?

    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "电影文件"
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
            let request = NSFetchRequest(entityName: "MovieFile")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieFileCell", forIndexPath: indexPath)
        
        if let movieFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? MovieFile {
            var fileName: String?
            var fileID: String?
            movieFile.managedObjectContext?.performBlockAndWait {
                fileName = movieFile.name
                fileID = movieFile.id
            }
            cell.textLabel?.text = fileName
            cell.detailTextLabel?.text = fileID
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let movieFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? MovieFile
        let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent((movieFile?.name!)! + (movieFile?.id!)! + ".rmvb")
        self.documentController = UIDocumentInteractionController(URL: fileURL)
        self.documentController?.delegate = self
        self.documentController?.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            if let movieFile = fetchedResultsController?.objectAtIndexPath(indexPath) as? MovieFile
            {
                let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent((movieFile.name!) + (movieFile.id!) + ".rmvb")
                if (FileManager.deleteFileOfURL(fileURL))
                {
                    managedObjectContext?.deleteObject(movieFile)
                } else {
                    errorAlert("Delete file failed")
                }
            }
        }
    }

    func errorAlert(errorMessage: String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "Movie", message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
