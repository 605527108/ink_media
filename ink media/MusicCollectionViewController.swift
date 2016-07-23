//
//  MusicCollectionViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/17/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MusicCollectionCell"

class MusicCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var readyToDisplay = false
    var waitingView: WaitingView?
    var blankView: UIView?
    let hotArtists = ["周杰伦" , "孙燕姿" , "张国荣" , "王菲" , "张靓颖" , "邓紫棋" , "陈慧琳" , "莫文蔚"]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "桃源音乐"
        fetchFirstPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MusicCollectionViewController.failToFetchMusic(_:)), name: "NotificationFromMusicFetcher", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromMusicFetcher", object: nil)
        super.viewWillDisappear(animated)
    }

    var albums = [Album]() {
        didSet {
            if albums.count > 0
            {
                let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
                if connectToNKU!
                {
                    fetchThumbnailURL()
                }
            }
            collectionView?.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            albums.removeAll()
            self.collectionView?.reloadData()
            searchForAlbums()
            title = searchText
        }
    }
    
    private var lastFetcher: MusicFetcher?
    
    private var musicFetcher : MusicFetcher? {
        if let query = searchText where !query.isEmpty{
            return MusicFetcher(searchText: query)
        }
        return nil
    }
    
    var searchController: UISearchController!

    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchText = searchController.searchBar.text
        searchController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.placeholder = "搜索歌手或专辑名称"
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMusicDetailTVC"
        {
            if let cell = sender as? MusicCollectionViewCell,
                let indexPath = collectionView!.indexPathForCell(cell),
                let seguedToMDTVC = segue.destinationViewController as? MusicDetailTableViewController
            {
                let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
                seguedToMDTVC.connectToNKU = connectToNKU!
                seguedToMDTVC.album = albums[indexPath.row]
                if !connectToNKU!
                {
                    seguedToMDTVC.thumbnailImage = cell.albumThumbnail.image
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MusicCollectionViewCell
        cell.album = albums[indexPath.row]
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if !connectToNKU!
        {
            cell.albumThumbnail.image = UIImage(named: "music_offline_\(indexPath.row)")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let cellWidth = screenWidth / 2 - 8
        let cellHeight = cellWidth + 30
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    
    func fetchFirstPage()
    {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if connectToNKU == false
        {
            self.albums = Album.allAlbums()
        }
        else
        {
            addBlankView()
            readyToDisplay = false
            let randNum = time(nil) % hotArtists.count
            let firstPageFetcher = MusicFetcher(searchText: hotArtists[randNum], searchType: .artist)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
            {
                firstPageFetcher.fetchMultipleAlbums({ [weak weakSelf = self] newAlbums in
                    dispatch_async(dispatch_get_main_queue(), {
                        if !newAlbums.isEmpty {
                            weakSelf?.albums = newAlbums
                        }
                        else
                        {
                            weakSelf?.albums = Album.allAlbums()
                        }
                    })
                })
            }
        }
    }
    
    private func searchForAlbums()
    {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if connectToNKU!
        {
            addBlankView()
            readyToDisplay = false
            if let fetcher = musicFetcher {
                lastFetcher = fetcher
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    fetcher.fetchMultipleAlbums({ [weak weakSelf = self] newAlbums in
                        dispatch_async(dispatch_get_main_queue(), {
                            if (fetcher.searchText == (weakSelf?.lastFetcher)!.searchText) && (fetcher.searchType == (weakSelf?.lastFetcher)!.searchType){
                                if !newAlbums.isEmpty {
                                    weakSelf?.albums = newAlbums
                                }
                            }
                            let anotherFetcher = MusicFetcher(searchText: self.searchText!, searchType: .artist)
                            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                            {
                                anotherFetcher.fetchMultipleAlbums({ [weak weakSelf = self] newAlbums in
                                    dispatch_async(dispatch_get_main_queue(), {
                                        if !newAlbums.isEmpty {
                                            weakSelf?.albums.appendContentsOf(newAlbums)
                                        }
                                        if weakSelf!.albums.isEmpty
                                        {
                                            weakSelf?.readyToDisplay = true
                                        }
                                    })
                                })
                            }
                        })
                    })
                }
            }
        }
        else
        {
            var newAlbums = [Album]()
            for album in Album.allAlbums() {
                if let _ = album.name?.rangeOfString(searchText!) {
                    newAlbums.append(album)
                }
            }
            if !newAlbums.isEmpty {
                self.albums = newAlbums
            }
        }
    }
    
    func fetchThumbnailURL()
    {
        let count = albums.count - 1
        if count > -1
        {
            var noConnectionCount = 0
            for index in 0...count
            {
                let thumbnailURLFetcher = MusicFetcher(searchText: albums[index].name!, searchType: .thumbnailURL)
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    thumbnailURLFetcher.fetchAlbumThumbnailURL({ [weak weakSelf = self] thumbnailURL in
                        dispatch_async(dispatch_get_main_queue(), {
                            if thumbnailURL != nil
                            {
                                weakSelf?.albums[index].thumbnailURL = thumbnailURL
                                weakSelf?.fetchThumbnail(index)
                            }
                            else
                            {
                                if noConnectionCount == count
                                {
                                    weakSelf?.readyToDisplay = true
                                    weakSelf?.errorAlert("无法获取专辑图片")
                                }
                                noConnectionCount = noConnectionCount + 1
                            }
                        })
                    })
                }
            }
        }
    }
    
    func fetchThumbnail(index: Int)
    {
        let thumbnailFetcher = MusicFetcher(searchText: albums[index].thumbnailURL!, searchType: .thumbnail)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            thumbnailFetcher.fetchAlbumThumbnail({ [weak weakSelf = self] thumbnailData in
                dispatch_async(dispatch_get_main_queue(), {
                    if thumbnailData != nil
                    {
                        weakSelf?.albums[index].thumbnailData = thumbnailData
                        let indexPath = NSIndexPath(forItem: index, inSection: 0)
                        weakSelf?.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        if let count = weakSelf?.albums.count where index == (count - 1)
                        {
                            weakSelf?.readyToDisplay = true
                        }
                    }
                })
            })
        }
    }
    
    func failToFetchMusic(notification:NSNotification)
    {
        if let musicErrorInfo = notification.userInfo!["errorInfo"] as? String
        {
            print(musicErrorInfo)
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

extension MusicCollectionViewController: WaitingViewDelegate {
    func checkReadyToDisplay() -> Bool
    {
        return readyToDisplay
    }
    
    func readyToBeRemoved()
    {
        self.blankView?.removeFromSuperview()
        collectionView?.userInteractionEnabled = true
        if albums.count == 0
        {
            errorAlert("Sorry啦没找到")
        }
    }
    
    func addBlankView()
    {
        blankView = UIView(frame: self.collectionView!.bounds)
        blankView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.addSubview(blankView!)
        let boxSize: CGFloat = 100.0
        waitingView = WaitingView(frame: CGRect(x: view.bounds.width / 2 - boxSize / 2,
            y: view.bounds.height / 2 - boxSize,
            width: boxSize,
            height: boxSize))
        waitingView?.waitingViewdelegate = self
        blankView?.addSubview(waitingView!)
        waitingView?.drawRedAnimatedRectangle()
        collectionView?.userInteractionEnabled = false
    }
}