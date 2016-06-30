//
//  MovieDetailTableViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/17/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailTableViewController: UITableViewController {

    private struct Storyboard {
        static let MovieDetailTableViewCellIdentifier = "MovieDetail"
        static let MovieContentTableViewCellIdentifier = "MovieContent"
        static let MovieDownloadTableViewCellIdentifier = "MovieDownload"
    }
    
    var activeDownloads = [String: Download]()
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var connectToNKU = true
    
    var movie: Movie? {
        didSet {
            if connectToNKU
            {
                fetchDetail()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MovieDetailTableViewController.failToFetchMovie(_:)), name: "NotificationFromMovieFetcher", object: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromMovieFetcher", object: nil)
    }
    
    func failToFetchMovie(notification:NSNotification)
    {
        let movieErrorInfo = notification.userInfo!["errorInfo"] as! String
        errorAlert(movieErrorInfo)
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
    
    func fetchDetail() {
        let detailFetcher = MovieFetcher(searchText: movie!.id!, searchType: .detail)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            detailFetcher.fetchMovieDetail { [weak weakSelf = self] newMovie in
                if newMovie != nil {
                    weakSelf?.movie!.info = newMovie!.info
                    weakSelf?.movie!.content = newMovie!.content
                    weakSelf?.videos = newMovie!.videos
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if let thumbnailData = movie?.thumbnailData
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
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else if section == 1
        {
            return 1
        }
        else if section == 2
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
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MovieDetailTableViewCellIdentifier)!
            if let movieDetailTableViewCell = cell as? MovieDetailTableViewCell
            {
                movieDetailTableViewCell.movie = movie
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MovieContentTableViewCellIdentifier)!
            if let movieContentTableViewCell = cell as? MovieContentTableViewCell
            {
                movieContentTableViewCell.movieContent = movie?.content
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MovieDownloadTableViewCellIdentifier, forIndexPath: indexPath)
            if let movieDownloadTableViewCell = cell as? MovieDownloadTableViewCell
            {
                let video = videos![indexPath.row]
                dispatch_async(dispatch_get_main_queue(), { 
                    movieDownloadTableViewCell.titleLabel.text = video.name
                    movieDownloadTableViewCell.idLabel.text = video.id
                    movieDownloadTableViewCell.delegate = self
                    
                    
                    var showDownloadControls = false
                    if let url = video.url , download = self.activeDownloads[url]
                    {
                        showDownloadControls = true
                        let title = (download.isDownloading) ? "Pause" : "Resume"
                        movieDownloadTableViewCell.pauseButton.setTitle(title, forState: UIControlState.Normal)
                        movieDownloadTableViewCell.progressView.progress = download.progress
                        movieDownloadTableViewCell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
                    }
                    movieDownloadTableViewCell.progressView.hidden = !showDownloadControls
                    movieDownloadTableViewCell.progressLabel.hidden = !showDownloadControls
                    movieDownloadTableViewCell.selectionStyle = video.downloaded! ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
                    movieDownloadTableViewCell.downloadButton.hidden = video.downloaded! || showDownloadControls
                    movieDownloadTableViewCell.pauseButton.hidden = !showDownloadControls
                    movieDownloadTableViewCell.cancelButton.hidden = !showDownloadControls
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
                    let request = NSFetchRequest(entityName: "MovieFile")
                    request.predicate = NSPredicate(format: "id = %@", weakSelf!.videos![index].id!)
                    if ((try? weakSelf?.managedObjectContext!.executeFetchRequest(request))?!.first as? MovieFile) == nil
                    {
                        weakSelf!.videos![index].downloaded = false
                        weakSelf!.fetchVideoURL(index)
                    }
                    else
                    {
                        weakSelf!.videos![index].downloaded = true
                        dispatch_async(dispatch_get_main_queue(), {
                            weakSelf?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 2)], withRowAnimation: .None)
                        })
                    }
                }
            }
        }
    }
    
    func fetchVideoURL(index: Int)
    {
        let videoURLFetcher = MovieFetcher(searchText: videos![index].id!, searchType: .link)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            videoURLFetcher.fetchMovieURL(self.videos![index].name!, handler: { [weak weakSelf = self] url in
                dispatch_async(dispatch_get_main_queue(), {
                    if url != nil {
                        weakSelf?.videos![index].url = url
                        dispatch_async(dispatch_get_main_queue(), {
                            weakSelf?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 2)], withRowAnimation: .None)
                        })
                    }
                })
            })
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
}

extension MovieDetailTableViewController: MovieDownloadTableViewCellDelegate {
    
    
    func pauseTapped(cell: MovieDownloadTableViewCell) {
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
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .None)
        }
    }
    
    func resumeTapped(cell: MovieDownloadTableViewCell) {
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
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .None)
            }
        }
    }
    
    func cancelTapped(cell: MovieDownloadTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let url = videos![indexPath.row].url
            {
                if let download = activeDownloads[url] {
                    download.downloadTask?.cancel()
                    activeDownloads[url] = nil
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .None)
            }
        }
    }
    
    func downloadTapped(cell: MovieDownloadTableViewCell) {
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
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .None)
            }
        }
    }
}

extension MovieDetailTableViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if let index = videoIndexForDownloadTask(downloadTask)
        {
            let persistentURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent(videos![index].name! + videos![index].id! + ".rmvb")
            if(FileManager.moveTempFileToDocumentDirectory(location,toURL: persistentURL) == false)
            {
                videos![index].downloaded = false
                errorAlert("下载失败")
            }
            else
            {
                self.managedObjectContext!.performBlock { [weak weakSelf = self] in
                    _ = MovieFile.movieFileWithLocalURL((weakSelf?.videos![index].name!)!, fileID: (weakSelf?.videos![index].id!)!, inManagedObjectContext: self.managedObjectContext!)
                    do {
                        try self.managedObjectContext?.save()
                        weakSelf?.videos![index].downloaded = true
                    } catch let error {
                        print("Core Data Error: \(error)")
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 2)], withRowAnimation: .None)
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
            if let trackIndex = videoIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 2)) as? MovieDownloadTableViewCell {
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
extension MovieDetailTableViewController: NSURLSessionDelegate {
    
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
