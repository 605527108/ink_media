//
//  MovieCollectionViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/16/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MovieCollectionCell"

class MovieCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var searchController: UISearchController!
    var connectToNKU = true
    var readyToDisplay = false
    var waitingView: WaitingView?
    var blankView: UIView?
    
    private var lastFetcher : MovieFetcher?
    
    private var movieSearcher: MovieFetcher? {
        if let query = searchText where !query.isEmpty{
            return MovieFetcher(searchText: query)
        }
        return nil
    }
    
    var movies = [Movie]() {
        didSet {
            if movies.count > 0
            {
                fetchThumbnails()
            }
            collectionView?.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            movies.removeAll()
            self.collectionView?.reloadData()
            searchForMovies()
            title = searchText
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchText = searchController.searchBar.text
        searchController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "搜索电影或剧集名称"
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "光影传奇"
        fetchFirstPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromMovieFetcher", object: nil)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MovieCollectionViewController.failToFetchMovie(_:)), name: "NotificationFromMovieFetcher", object: nil)
    }
    
    func failToFetchMovie(notification:NSNotification)
    {
        if let movieErrorInfo = notification.userInfo!["errorInfo"] as? String
        {
            print(movieErrorInfo)
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMovieDetailTVC"
        {
            if let cell = sender as? MovieCollectionViewCell,
                let indexPath = collectionView!.indexPathForCell(cell),
                let seguedToMDTVC = segue.destinationViewController as? MovieDetailTableViewController
            {
                seguedToMDTVC.connectToNKU = self.connectToNKU
                seguedToMDTVC.movie = movies[indexPath.row]
            }
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MovieCollectionViewCell
        cell.movie = movies[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let cellWidth = screenWidth / 2 - 8
        let cellHeight = cellWidth / 5 * 7 + 35
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    private func fetchFirstPage()
    {
        addBlankView()
        readyToDisplay = false
        let firstPageFetcher = MovieFetcher(searchText: "", searchType: .index)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            firstPageFetcher.fetchMultipleMovies({ [weak weakSelf = self] newMovies in
                dispatch_async(dispatch_get_main_queue(), {
                    if !newMovies.isEmpty {
                        weakSelf?.movies = newMovies
                    } else {
                        weakSelf?.connectToNKU = false
                        weakSelf?.movies = Movie.allMovies()
                    }
                })
            })
        }
    }
    
    private func searchForMovies()
    {
        addBlankView()
        readyToDisplay = false
        if connectToNKU {
            if let fetcher = movieSearcher {
                lastFetcher = fetcher
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    fetcher.fetchMultipleMovies({ [weak weakSelf = self] newMovies in
                        dispatch_async(dispatch_get_main_queue(), {
                            if (fetcher.searchText == (weakSelf?.lastFetcher)!.searchText) && (fetcher.searchType == (weakSelf?.lastFetcher)!.searchType){
                                if !newMovies.isEmpty {
                                    weakSelf?.movies = newMovies
                                }
                                else
                                {
                                    weakSelf?.readyToDisplay = true
                                }
                            }
                        })
                    })
                }
            }
        } else {
            var newMovies = [Movie]()
            for movie in Movie.allMovies()
            {
                if let _ = movie.name?.rangeOfString(searchText!)
                {
                    newMovies.append(movie)
                }
            }
            if !newMovies.isEmpty {
                self.movies = newMovies
            }
            else
            {
                self.readyToDisplay = true
            }
        }
        
    }
    
    func fetchThumbnails()
    {
        let count = movies.count - 1
        if count > -1
        {
            for index in 0...count {
                var thumbnailFetcher: MovieFetcher?
                if connectToNKU {
                    thumbnailFetcher = MovieFetcher(searchText: movies[index].id!, searchType: .thumbnailOnline)
                } else {
                    thumbnailFetcher = MovieFetcher(searchText: movies[index].id!, searchType: .thumbnailOffline)
                }
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    thumbnailFetcher!.fetchMovieThumbnail({ [weak weakSelf = self] thumbnailData in
                        dispatch_async(dispatch_get_main_queue(), {
                            if thumbnailData != nil {
                                weakSelf!.movies[index].thumbnailData = thumbnailData
                                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                                weakSelf?.collectionView?.reloadItemsAtIndexPaths([indexPath])
                                if index == count
                                {
                                    weakSelf?.readyToDisplay = true
                                }
                            }
                        })
                    })
                }
            }
        }
    }
}

extension MovieCollectionViewController: WaitingViewDelegate {
    func checkReadyToDisplay() -> Bool
    {
        return readyToDisplay
    }
    
    func readyToBeRemoved()
    {
        self.blankView?.removeFromSuperview()
        collectionView?.userInteractionEnabled = true
        if self.movies.count == 0
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