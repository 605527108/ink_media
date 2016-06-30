//
//  CartoonFileTableViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/19/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class CartoonFileTableViewCell: UITableViewCell, NSURLSessionDownloadDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var videoNameLabel: UILabel!
    
    @IBAction func downloadVideo(sender: UIButton) {
        if downloadStatus == .notDownloaded {
            downloadStatus = .downloading
            downloadButton.setTitle("取消", forState: .Normal)
            self.downloadProgress?.hidden = false
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let downloadSession = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
            let downLoadURL = NSURL(string: videoURL!)
            let request = NSURLRequest(URL: downLoadURL!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: Double(10))
            self.downloadTask = downloadSession.downloadTaskWithRequest(request)
            downloadTask!.resume()
        }
        else if downloadStatus == .downloading
        {
            downloadTask?.cancel()
        }
    }
    internal enum DownloadStatus {
        case downloaded
        case notDownloaded
        case downloading
    }
    
    
    internal var videoName: String? {
        didSet {
            updateUI()
        }
    }
    internal var videoID: String? {
        didSet {
            checkDownloaded()
        }
    }
    
    var downloadStatus: DownloadStatus = .notDownloaded {
        didSet {
            if downloadStatus == .downloaded {
                progress = 1
            } else if downloadStatus == .notDownloaded{
                progress = 0
            }
        }
    }
    var progress: Double? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                if (self.progress != 0 && self.progress != 1)
                {
                    self.downloadProgress?.setProgress(Float(self.progress!), animated: true)
                } else if self.progress == 0 {
                    self.downloadProgress?.setProgress(0, animated: false)
                    self.downloadProgress?.hidden = true
                    self.downloadButton.setTitle("下载", forState: .Normal)
                } else if self.progress == 1 {
                    self.downloadProgress?.setProgress(0, animated: false)
                    self.downloadProgress?.hidden = true
                    self.downloadButton.setTitle("已下载", forState: .Normal)
                }
            }
        }
    }
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var videoURL: String?
    
    var downloadTask: NSURLSessionDownloadTask?
    
    func updateUI()
    {
        self.downloadProgress?.setProgress(0, animated: false)
        self.downloadProgress?.hidden = true
        videoNameLabel?.text = nil
        
        if let name = self.videoName
        {
            videoNameLabel.text = name
        }
    }
    
    func fetchVideoURL()
    {
        let videoURLFetcher = CartoonFetcher(searchText: videoID!, searchType: .link)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            videoURLFetcher.fetchCartoonURL({ [weak weakSelf = self] url in
                dispatch_async(dispatch_get_main_queue(), {
                    if url != nil {
                        weakSelf?.videoURL = url
                    }
                })
            })
        }
    }
    
    func checkDownloaded()
    {
        managedObjectContext!.performBlockAndWait { [weak weakSelf = self] in
            let request = NSFetchRequest(entityName: "CartoonFile")
            request.predicate = NSPredicate(format: "id = %@", weakSelf!.videoID!)
            if ((try? self.managedObjectContext!.executeFetchRequest(request))?.first as? CartoonFile) == nil
            {
                weakSelf?.fetchVideoURL()
                weakSelf?.downloadStatus = .notDownloaded
            }
            else
            {
                weakSelf?.downloadStatus = .downloaded
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let persistentURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent(videoName! + videoID! + ".mp4")
        if(FileManager.moveTempFileToDocumentDirectory(location,toURL: persistentURL) == false)
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonDownloader", object: nil, userInfo: ["errorInfo":"Can not move temp file to Document directory"])
            downloadStatus = .notDownloaded
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonDownloader", object: nil, userInfo: ["videoName":videoName!,"videoID":videoID!])
            downloadStatus = .downloaded
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if(error != nil)
        {
            if error?.localizedDescription != "cancelled" {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieDownloader", object: nil, userInfo: ["errorInfo":(error?.localizedDescription)!])
            }
            else
            {
                print(error?.localizedDescription)
            }
            downloadStatus = .notDownloaded
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }
}
