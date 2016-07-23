//
//  CartoonCollectionViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/18/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CartoonCollectionCell"

class CartoonCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var searchController: UISearchController!
    var readyToDisplay = false
    var waitingView: WaitingView?
    var blankView: UIView?
    
    private var lastFetcher : CartoonFetcher?
    
    private var cartoonSearcher: CartoonFetcher? {
        if let query = searchText where !query.isEmpty{
            return CartoonFetcher(searchText: query)
        }
        return nil
    }
    
    var cartoons = [Cartoon]() {
        didSet {
            if cartoons.count > 0
            {
                let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
                if connectToNKU!
                {
                    fetchThumbnails()
                }
            }
            collectionView?.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            cartoons.removeAll()
            self.collectionView?.reloadData()
            searchForCartoon()
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
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.placeholder = "搜索动漫名称"
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "12Club动漫"
        fetchFirstPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationFromCartoonFetcher", object: nil)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CartoonCollectionViewController.failToFetchCartoon(_:)), name: "NotificationFromCartoonFetcher", object: nil)
    }
    
    func fetchFirstPage() {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if connectToNKU == false
        {
            self.cartoons = Cartoon.allCartoons()
        }
        else
        {
            addBlankView()
            readyToDisplay = false
            let firstPageFetcher = CartoonFetcher(searchText: "", searchType: .index)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
            {
                firstPageFetcher.fetchMultipleCartoons({ [weak weakSelf = self] newCartoons in
                    dispatch_async(dispatch_get_main_queue(), {
                        if !newCartoons.isEmpty {
                            weakSelf?.cartoons = newCartoons
                        } else {
                            weakSelf?.cartoons = Cartoon.allCartoons()
                        }
                    })
                })
            }
        }
    }
    
    func searchForCartoon() {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if connectToNKU! {
            addBlankView()
            readyToDisplay = false
            if let fetcher = cartoonSearcher {
                lastFetcher = fetcher
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    fetcher.fetchMultipleCartoons({ [weak weakSelf = self] newCartoons in
                        dispatch_async(dispatch_get_main_queue(), {
                            if (fetcher.searchText == (weakSelf?.lastFetcher)!.searchText) && (fetcher.searchType == (weakSelf?.lastFetcher)!.searchType){
                                if !newCartoons.isEmpty {
                                    weakSelf?.cartoons = newCartoons
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
        }
        else
        {
            var newCartoons = [Cartoon]()
            let localCartoons = Cartoon.allCartoons()
            for cartoon in localCartoons
            {
                if let _ = cartoon.name?.rangeOfString(searchText!)
                {
                    newCartoons.append(cartoon)
                }
            }
            if !newCartoons.isEmpty {
                self.cartoons = newCartoons
            }
        }
    }
    
    func fetchThumbnails()
    {
        let count = cartoons.count - 1
        
        if count > -1
        {
            for index in 0...count
            {
                let thumbnailFetcher = CartoonFetcher(searchText: cartoons[index].thumbnailURL!, searchType: .thumbnailOnline)
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
                {
                    thumbnailFetcher.fetchCartoonThumbnail({ [weak weakSelf = self] thumbnailData in
                        dispatch_async(dispatch_get_main_queue(), {
                            if thumbnailData != nil {
                                weakSelf!.cartoons[index].thumbnailData = thumbnailData
                                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                                weakSelf?.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            }
                        })
                    })
                    if index == count
                    {
                        self.readyToDisplay = true
                    }
                }
            }
        }
    }
    
    func failToFetchCartoon(notification:NSNotification)
    {
        if let cartoonErrorInfo = notification.userInfo!["errorInfo"] as? String
        {
            print(cartoonErrorInfo)
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCartoonDetailTVC"
        {
            if let cell = sender as? CartoonCollectionViewCell,
                let indexPath = collectionView!.indexPathForCell(cell),
                let seguedToCDTVC = segue.destinationViewController as? CartoonDetailTableViewController
            {
                seguedToCDTVC.cartoon = cartoons[indexPath.row]
                let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
                seguedToCDTVC.connectToNKU = connectToNKU!
                if !connectToNKU!
                {
                    seguedToCDTVC.thumbnailImage = cell.cartoonThumbnailImageView.image
                }
            }
        }
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartoons.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CartoonCollectionViewCell
        cell.cartoon = cartoons[indexPath.row]
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        if !connectToNKU!
        {
            cell.cartoonThumbnailImageView.image = UIImage(named: "cartoon_offline_\((cartoons[indexPath.row].id)!)")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let cellWidth = screenWidth / 2 - 8
        let cellHeight = cellWidth / 2 * 3 + 35
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }

}
extension CartoonCollectionViewController: WaitingViewDelegate {
    func checkReadyToDisplay() -> Bool
    {
        return readyToDisplay
    }
    
    func readyToBeRemoved()
    {
        self.blankView?.removeFromSuperview()
        collectionView?.userInteractionEnabled = true
        
        if cartoons.count == 0
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