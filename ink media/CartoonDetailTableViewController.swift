//
//  CartoonDetailTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/18/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class CartoonDetailTableViewController: UITableViewController {
    
    private struct Storyboard {
        static let CartoonDetailTableViewCellIdentifier = "CartoonDetail"
        static let CartoonDownloadTableViewCellIdentifier = "CartoonDownload"
        
    }
    
    var activeDownloads = [String: Download]()
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var connectToNKU = true

    var cartoon: Cartoon? {
        didSet {
            if connectToNKU
            {
                fetchDetail()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CartoonDetailTableViewController.failToFetchCartoon(_:)), name: "NotificationFromCartoonFetcher", object: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromCartoonFetcher", object: nil)
    }
    
    func failToFetchCartoon(notification:NSNotification)
    {
        let cartoonErrorInfo = notification.userInfo!["errorInfo"] as! String
        errorAlert(cartoonErrorInfo)
    }
    
    func videoIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, video) in videos!.enumerate() {
                if url == video.url! {
                    return index
                }
            }
        }
        return nil
    }
    
    var videos : [Video]? {
        didSet {
            tableView.reloadData()
            checkDownloaded()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if let thumbnailData = cartoon?.thumbnailData
        {
            self.tableView.backgroundView = UIImageView(image: UIImage(data: thumbnailData))
            let blur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = self.tableView.bounds
            self.tableView.backgroundView!.insertSubview(blurView, atIndex: 0)
        }
        _ = self.downloadsSession
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else if section == 1
        {
            if let count = videos?.count
            {
                return count
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CartoonDetailTableViewCellIdentifier)!
            if let cartoonDetailTableViewCell = cell as? CartoonDetailTableViewCell
            {
                cartoonDetailTableViewCell.cartoon = cartoon
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CartoonDownloadTableViewCellIdentifier)!
            if let cartoonDownloadTableViewCell = cell as? CartoonDownloadTableViewCell
            {
                let video = videos![indexPath.row]
                dispatch_async(dispatch_get_main_queue(), {
                    cartoonDownloadTableViewCell.titleLabel.text = video.name
                    cartoonDownloadTableViewCell.idLabel.text = video.id
                    cartoonDownloadTableViewCell.delegate = self
                    
                    
                    var showDownloadControls = false
                    if let url = video.url, download = self.activeDownloads[url]
                    {
                        showDownloadControls = true
                        let title = (download.isDownloading) ? "Pause" : "Resume"
                        cartoonDownloadTableViewCell.pauseButton.setTitle(title, forState: UIControlState.Normal)
                        cartoonDownloadTableViewCell.progressView.progress = download.progress
                        cartoonDownloadTableViewCell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
                    }
                    cartoonDownloadTableViewCell.progressView.hidden = !showDownloadControls
                    cartoonDownloadTableViewCell.progressLabel.hidden = !showDownloadControls
                    cartoonDownloadTableViewCell.selectionStyle = video.downloaded! ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
                    cartoonDownloadTableViewCell.downloadButton.hidden = video.downloaded! || showDownloadControls
                    cartoonDownloadTableViewCell.pauseButton.hidden = !showDownloadControls
                    cartoonDownloadTableViewCell.cancelButton.hidden = !showDownloadControls
                })
            }
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func checkDownloaded()
    {
        if let numOfVideos = videos?.count where numOfVideos > 0
        {
            for index in 0...(numOfVideos-1)
            {
                managedObjectContext!.performBlock { [weak weakSelf = self] in
                    let request = NSFetchRequest(entityName: "CartoonFile")
                    request.predicate = NSPredicate(format: "id = %@", weakSelf!.videos![index].id!)
                    if ((try? weakSelf?.managedObjectContext!.executeFetchRequest(request))?!.first as? CartoonFile) == nil
                    {
                        weakSelf!.videos![index].downloaded = false
                        weakSelf!.fetchVideoURL(index)
                    }
                    else
                    {
                        weakSelf!.videos![index].downloaded = true
                        dispatch_async(dispatch_get_main_queue(), {
                            weakSelf?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .None)
                        })
                    }
                }
            }
        }
    }
    
    func fetchVideoURL(index: Int)
    {
        let videoURLFetcher = CartoonFetcher(searchText: videos![index].id!, searchType: .link)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            videoURLFetcher.fetchCartoonURL({ [weak weakSelf = self] url in
                dispatch_async(dispatch_get_main_queue(), {
                    if url != nil {
                        weakSelf?.videos![index].url = url
                        dispatch_async(dispatch_get_main_queue(), {
                            weakSelf?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .None)
                        })
                    }
                })
            })
        }
    }
    
    func fetchDetail()
    {
        let detailFetcher = CartoonFetcher(searchText: cartoon!.id!, searchType: .detail)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            detailFetcher.fetchCartoonDetail { [weak weakSelf = self] newCartoon in
                if newCartoon != nil {
                    weakSelf?.cartoon!.info = newCartoon!.info
                    weakSelf?.videos = newCartoon!.videos
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


extension CartoonDetailTableViewController: CartoonDownloadTableViewCellDelegate {
    
    
    func pauseTapped(cell: CartoonDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let download = activeDownloads[videos![indexPath.row].url!] {
                if download.isDownloading {
                    download.downloadTask?.cancelByProducingResumeData { data in
                        if data != nil {
                            download.resumeData = data
                        }
                    }
                    download.isDownloading = false
                }
            }
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 1)], withRowAnimation: .None)
        }
    }
    
    func resumeTapped(cell: CartoonDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let url = videos![indexPath.row].url
            {
                if let download = activeDownloads[url] {
                    if let resumeData = download.resumeData {
                        download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
                        download.downloadTask!.resume()
                        download.isDownloading = true
                    } else if let videoURL = NSURL(string: url) {
                        download.downloadTask = downloadsSession.downloadTaskWithURL(videoURL)
                        download.downloadTask!.resume()
                        download.isDownloading = true
                    }
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 1)], withRowAnimation: .None)
            }
        }
    }
    
    func cancelTapped(cell: CartoonDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let url = videos![indexPath.row].url
            {
                if let download = activeDownloads[url] {
                    download.downloadTask?.cancel()
                    activeDownloads[url] = nil
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 1)], withRowAnimation: .None)
            }
        }
    }
    
    func downloadTapped(cell: CartoonDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell)
        {
            if let url = videos![indexPath.row].url
            {
                if let videoURL = NSURL(string: url)
                {
                    let download = Download.init(indexPath: indexPath)
                    download.downloadTask = downloadsSession.downloadTaskWithURL(videoURL)
                    download.downloadTask!.resume()
                    download.isDownloading = true
                    activeDownloads[url] = download
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 1)], withRowAnimation: .None)
            }
        }
    }
}

extension CartoonDetailTableViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if let index = videoIndexForDownloadTask(downloadTask)
        {
            let persistentURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent(videos![index].name! + videos![index].id! + ".mp4")
            if(FileManager.moveTempFileToDocumentDirectory(location,toURL: persistentURL) == false)
            {
                videos![index].downloaded = false
                errorAlert("下载失败")
            }
            else
            {
                self.managedObjectContext!.performBlock { [weak weakSelf = self] in
                    _ = CartoonFile.cartoonFileWithLocalURL((weakSelf?.videos![index].name!)!, fileID: (weakSelf?.videos![index].id!)!, inManagedObjectContext: self.managedObjectContext!)
                    do {
                        try self.managedObjectContext?.save()
                        weakSelf?.videos![index].downloaded = true
                    } catch let error {
                        print("Core Data Error: \(error)")
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .None)
            })
        }
        
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            activeDownloads[url] = nil
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // 1
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString,
            download = activeDownloads[downloadUrl] {
            // 2
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            // 3
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            // 4
            if let trackIndex = videoIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 1)) as? CartoonDownloadTableViewCell {
                dispatch_async(dispatch_get_main_queue(), {
                    trackCell.progressView.progress = download.progress
                    trackCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil
        {
            print(error?.localizedDescription)
        }
    }
    
}
extension CartoonDetailTableViewController: NSURLSessionDelegate {
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }
}
