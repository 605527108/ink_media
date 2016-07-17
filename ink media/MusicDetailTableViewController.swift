//
//  MusicDetailTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/15/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class MusicDetailTableViewController: UITableViewController {

    var connectToNKU = true
    
    var thumbnailImage: UIImage? {
        didSet {
            self.tableView.backgroundView = UIImageView(image: thumbnailImage)
            let blur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = self.tableView.bounds
            self.tableView.backgroundView!.insertSubview(blurView, atIndex: 0)
        }
    }
    
    private struct Storyboard {
        static let AlbumDetailTableViewCellIdentifier = "AlbumDetail"
        static let MusicDownloadTableViewCellIdentifier = "MusicDownload"
    }
    
    var activeDownloads = [String: Download]()
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    internal var album: Album? {
        didSet{
            if connectToNKU
            {
                getDetail()
            }
            else
            {
                musicCollection = album?.sounds
            }
        }
    }
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if let thumbnailData = album?.thumbnailData
        {
            self.tableView.backgroundView = UIImageView(image: UIImage(data: thumbnailData))
            let blur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = self.tableView.bounds
            self.tableView.backgroundView!.insertSubview(blurView, atIndex: 0)
        }
        _ = self.downloadsSession
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MusicDetailTableViewController.failToFetchMusic(_:)), name: "NotificationFromMusicFetcher", object: nil)

        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromMusicFetcher", object: nil)
    }
    
    func failToFetchMusic(notification:NSNotification)
    {
        let musicErrorInfo = notification.userInfo!["errorInfo"] as! String
        errorAlert(musicErrorInfo)
    }
    
    func videoIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, music) in musicCollection!.enumerate() {
                if url == music.url! {
                    return index
                }
            }
        }
        return nil
    }
    
    internal var musicCollection: [Music]?
        {
        didSet{
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            checkDownloaded()
        }
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
        } else if section == 1
        {
            return (musicCollection == nil) ? 0 : musicCollection!.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0
        {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AlbumDetailTableViewCellIdentifier)!
            if let albumCell = cell as? AlbumDetailTableViewCell
            {
                albumCell.album = album!
                if !connectToNKU
                {
                    albumCell.albumThumbnail.image = thumbnailImage
                }
            }

        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MusicDownloadTableViewCellIdentifier, forIndexPath: indexPath)
            if let musicCell = cell as? MusicDownloadTableViewCell
            {
                let music = musicCollection![indexPath.row]
                dispatch_async(dispatch_get_main_queue(), {
                    musicCell.titleLabel.text = music.name
                    musicCell.idLabel.text = music.id
                    musicCell.delegate = self
                    
                    
                    var showDownloadControls = false
                    if self.connectToNKU
                    {
                        if let url = music.url, download = self.activeDownloads[url]
                        {
                            showDownloadControls = true
                            let title = (download.isDownloading) ? "Pause" : "Resume"
                            musicCell.pauseButton.setTitle(title, forState: UIControlState.Normal)
                            musicCell.progressView.progress = download.progress
                            musicCell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
                        }
                        musicCell.progressView.hidden = !showDownloadControls
                        musicCell.progressLabel.hidden = !showDownloadControls
                        musicCell.selectionStyle = music.downloaded! ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
                        musicCell.downloadButton.hidden = music.downloaded! || showDownloadControls
                        musicCell.pauseButton.hidden = !showDownloadControls
                        musicCell.cancelButton.hidden = !showDownloadControls
                    }
                    else
                    {
                        musicCell.progressView.hidden = true
                        musicCell.progressLabel.hidden = true
                        musicCell.downloadButton.hidden = true
                        musicCell.pauseButton.hidden = true
                        musicCell.cancelButton.hidden = true
                    }
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
        if let numOfMusics = musicCollection?.count where numOfMusics > 0
        {
            for index in 0...(numOfMusics-1)
            {
                managedObjectContext!.performBlock { [weak weakSelf = self] in
                    let request = NSFetchRequest(entityName: "MusicFile")
                    request.predicate = NSPredicate(format: "id = %@", weakSelf!.musicCollection![index].id!)
                    if ((try? weakSelf?.managedObjectContext!.executeFetchRequest(request))?!.first as? MusicFile) != nil
                    {
                        weakSelf!.musicCollection![index].downloaded = true
                        
                    } else
                    {
                        weakSelf!.musicCollection![index].downloaded = false
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        weakSelf?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .None)
                    })
                }
            }
        }
    }
    
    private func getDetail()
    {
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        
        let searchQuery = "artist="+album!.artist!+"&searchstring="+album!.name!
        let detailFetcher = MusicFetcher(searchText: searchQuery.stringByAddingPercentEscapesUsingEncoding(gbkEncoding)!, searchType: .music)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            detailFetcher.fetchMultipleMusic { [weak weakSelf = self] newMusicCollection in
                dispatch_async(dispatch_get_main_queue(), {
                    if !newMusicCollection.isEmpty {
                        weakSelf?.musicCollection = newMusicCollection
                    }
                })
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

}


extension MusicDetailTableViewController: MusicDownloadTableViewCellDelegate {
    
    
    func pauseTapped(cell: MusicDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let download = activeDownloads[musicCollection![indexPath.row].url!] {
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
    
    func resumeTapped(cell: MusicDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let url = musicCollection![indexPath.row].url
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
    
    func cancelTapped(cell: MusicDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let url = musicCollection![indexPath.row].url
            {
                if let download = activeDownloads[url] {
                    download.downloadTask?.cancel()
                    activeDownloads[url] = nil
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 1)], withRowAnimation: .None)
            }
        }
    }
    
    func downloadTapped(cell: MusicDownloadTableViewCell) {

        NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMuiscFile", object: nil, userInfo: ["signal":"add"])
        if let indexPath = tableView.indexPathForCell(cell)
        {
            if let url = musicCollection![indexPath.row].url
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

extension MusicDetailTableViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if let index = videoIndexForDownloadTask(downloadTask)
        {
            let persistentURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent(musicCollection![index].name! + musicCollection![index].id! + ".mp3")
            if(FileManager.moveTempFileToDocumentDirectory(location,toURL: persistentURL) == false)
            {
                musicCollection![index].downloaded = false
                errorAlert("下载失败")
            }
            else
            {
                self.managedObjectContext!.performBlock { [weak weakSelf = self] in
                    _ = MusicFile.musicFileWithLocalURL((weakSelf?.musicCollection![index])!, inManagedObjectContext: self.managedObjectContext!)
                    do {
                        try self.managedObjectContext?.save()
                        weakSelf?.musicCollection![index].downloaded = true
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
            if let trackIndex = videoIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 1)) as? MusicDownloadTableViewCell {
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
extension MusicDetailTableViewController: NSURLSessionDelegate {
    
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
