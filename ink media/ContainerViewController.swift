//
//  ContainerViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/19/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

enum SlideOutState {
    case SlideCollapsed
    case SlidePanelExpanded
}

enum PlayingStatus {
    case Playing
    case Stop
    case Pause
}

class ContainerViewController: UIViewController {

    var isObserving = false
    
    var playingStatus: PlayingStatus = .Stop
    
    var audioPlayer: AVQueuePlayer?
    
    var musicPlayingQueue = [Music]()
    
    var numOfMusicFile: Int?
    
    var currentPlayingIndex: Int?
    
    var centerNavigationController: UINavigationController!
    var centerViewController: AnyObject!
    var currentCenterViewControllerClass: String!
    var newCenterViewControllerClass: String?
    var currentState: SlideOutState = .SlideCollapsed {
        didSet {
            let shouldShowShadow = currentState != .SlideCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var slidePanelViewController: SlidePanelViewController?
    let centerPanelExpandedOffset: CGFloat = 60
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.movieCollectionViewController()
        currentCenterViewControllerClass = "光影传奇"
        newCenterViewControllerClass = currentCenterViewControllerClass
        centerNavigationController = UINavigationController(rootViewController: (centerViewController as! MovieCollectionViewController))
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        let slidePanelButton = UIBarButtonItem(image:UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.slidePanelTapped(_:)))
        centerViewController.navigationItem.leftBarButtonItem = slidePanelButton
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            becomeFirstResponder()
        }
        catch
        {
            print("Player set background failed")
        }
    }
    
    func slidePanelTapped(sender: AnyObject) {
        toggleSlidePanel()
    }
    
}

private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func slidePanelViewController() -> SlidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SlidePanelViewController") as? SlidePanelViewController
    }
    
    class func movieCollectionViewController() -> MovieCollectionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MovieCollectionViewController") as? MovieCollectionViewController
    }
    class func cartoonCollectionViewController() -> CartoonCollectionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CartoonCollectionViewController") as? CartoonCollectionViewController
    }
    class func tvViewController() -> TVViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TVViewController") as? TVViewController
    }
    class func musicCollectionViewController() -> MusicCollectionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MusicCollectionViewController") as? MusicCollectionViewController
    }
    class func musicFileTableViewController() -> MusicFileTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MusicFileTableViewController") as? MusicFileTableViewController
    }
    class func movieFileTableViewController() -> MovieFileTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MovieFileTableViewController") as? MovieFileTableViewController
    }
    class func cartoonFileTableViewController() -> CartoonFileTableViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CartoonFileViewController") as? CartoonFileTableViewController
    }
}


extension ContainerViewController {
    
    func toggleSlidePanel() {
        let notAlreadyExpanded = (currentState != .SlidePanelExpanded)
        if notAlreadyExpanded {
            addSlidePanelViewController()
            if let centerVC = self.centerViewController as? UIViewController
            {
                let blankView = UIView(frame: centerVC.view.bounds)
                blankView.tag = 1001
                centerVC.view.addSubview(blankView)
                let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTapGesture(_: )))
                recognizer.delegate = self
                blankView.addGestureRecognizer(recognizer)
            }
        } else {
            if let centerVC = self.centerViewController as? UIViewController
            {
                let blankView = centerVC.view.viewWithTag(1001)
                blankView?.removeFromSuperview()
            }
        }
        animateSlidePanel(notAlreadyExpanded)
    }
    
    func collapseSlidePanel()
    {
        switch (currentState) {
        case .SlidePanelExpanded:
            toggleSlidePanel()
        default:
            break
        }
    }
    
    func addSlidePanelViewController() {
        if (slidePanelViewController == nil) {
            slidePanelViewController = UIStoryboard.slidePanelViewController()
            addChildSlidePanelController(slidePanelViewController!)
        }
    }
    
    func addChildSlidePanelController(slidePanelController: SlidePanelViewController) {
        view.insertSubview(slidePanelController.view, atIndex: 0)
        slidePanelController.delegate = self
        addChildViewController(slidePanelController)
        slidePanelController.didMoveToParentViewController(self)
    }
    
    func animateSlidePanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .SlidePanelExpanded
            
            animateCenterPanelXPosition(CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { [weak weakSelf = self] finished in
                weakSelf?.currentState = .SlideCollapsed
                
                weakSelf?.slidePanelViewController!.view.removeFromSuperview()
                weakSelf?.slidePanelViewController = nil;
                if weakSelf?.newCenterViewControllerClass != weakSelf?.currentCenterViewControllerClass
                {
                    var newCenterViewController: UIViewController?
                    if weakSelf?.newCenterViewControllerClass == "光影传奇" {
                        newCenterViewController = UIStoryboard.movieCollectionViewController()
                        weakSelf?.currentCenterViewControllerClass = "光影传奇"
                        
                    } else if weakSelf?.newCenterViewControllerClass == "IPv6电视" {
                        newCenterViewController = UIStoryboard.tvViewController()
                        weakSelf?.currentCenterViewControllerClass = "IPv6电视"
                        
                    } else if weakSelf?.newCenterViewControllerClass == "12Club动漫" {
                        newCenterViewController = UIStoryboard.cartoonCollectionViewController()
                        weakSelf?.currentCenterViewControllerClass = "12Club动漫"
                        
                    } else if weakSelf?.newCenterViewControllerClass == "桃源音乐" {
                        newCenterViewController = UIStoryboard.musicCollectionViewController()
                        weakSelf?.currentCenterViewControllerClass = "桃源音乐"
                    } else if weakSelf?.newCenterViewControllerClass == "音乐播放器" {
                        newCenterViewController = UIStoryboard.musicFileTableViewController()
                        weakSelf?.currentCenterViewControllerClass = "音乐播放器"
                    } else if weakSelf?.newCenterViewControllerClass == "电影文件" {
                        newCenterViewController = UIStoryboard.movieFileTableViewController()
                        weakSelf?.currentCenterViewControllerClass = "电影文件"
                    } else if weakSelf?.newCenterViewControllerClass == "动漫播放器" {
                        newCenterViewController = UIStoryboard.cartoonFileTableViewController()
                        weakSelf?.currentCenterViewControllerClass = "动漫播放器"
                    }
                    let slidePanelButton = UIBarButtonItem(image:UIImage(named: "menu.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.slidePanelTapped(_:)))
                    weakSelf?.centerNavigationController?.popViewControllerAnimated(false)
                    weakSelf?.centerViewController = nil
                    weakSelf?.centerViewController = newCenterViewController
                    weakSelf?.centerViewController.navigationItem.leftBarButtonItem = slidePanelButton
                    weakSelf?.centerNavigationController?.pushViewController(newCenterViewController!, animated: false)
                }
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: SlidePanelViewControllerDelegate {
    func tabSelected(tabName: String?)
    {
        if tabName != currentCenterViewControllerClass {
            newCenterViewControllerClass = tabName
        }
        self.collapseSlidePanel()
    }
    
    func currentlyPlayingMusic() -> Music? {
        if playingOrStop() != .Stop
        {
            let music = musicPlayingQueue[currentPlayingIndex!]
            return music
        }
        return nil
    }
    func playingOrStop() -> PlayingStatus
    {
        return playingStatus
    }
    func currentlyDisplayingVC() -> String
    {
        return currentCenterViewControllerClass
    }
}

extension ContainerViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.processMusicPlayingQueue(_:)), name: "NotificationFromMuiscFile", object: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"NotificationFromMuiscFile", object: nil)
        deInitPlayer()
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        resignFirstResponder()
    }
    
    func processMusicPlayingQueue(notification: NSNotification)
    {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        let hasMusicFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMusicFile

        if let signal = notification.userInfo!["signal"] as? String //there's a control signal from musicfiletableview
        {
            if signal == "delete" // music deleted in musicfiletableview so need to deInitPlayer
            {
                deInitPlayer()
            }
            else if signal == "play" //signal play
            {
                if let playingQueue = notification.userInfo!["musicPlayingQueue"] as? [Music] //receive a play list, It's from fileTVC
                {
                    self.musicPlayingQueue = playingQueue
                    if playingQueue.count == 1
                    {
                        self.musicPlayingQueue.appendContentsOf(playingQueue)
                    }
                    numOfMusicFile = self.musicPlayingQueue.count
                    currentPlayingIndex = notification.userInfo!["startAtIndexPath"] as? Int
                    deInitPlayer()
                    initPlayer()
                }
                else //receive no play list, it's from slide's Notify
                {
                    if playingStatus == .Pause //currently pause
                    {
                        audioPlayer?.play()
                        playingStatus = .Playing
                        startObserving()
                    }
                    else if playingStatus == .Stop && connectToNKU == false && hasMusicFile == false
                    {
                        var playingQueue = [Music]()
                        playingQueue.append(Music(name: "南开大学校歌", id: "0"))
                        playingQueue.append(Music(name: "南开大学校歌", id: "0"))
                        self.musicPlayingQueue = playingQueue
                        numOfMusicFile = 2
                        currentPlayingIndex = 0
                        deInitPlayer()
                        initPlayer()
                    }
                }
            }
            else if signal == "pause" //it's from slide's Notify
            {
                if playingStatus == .Playing
                {
                    audioPlayer?.pause()
                    playingStatus = .Pause
                    stopObserving()
                }
            }
            else if signal == "add" || signal == "delete"
            {
                deInitPlayer()
            }
        }
    }
    
    func initPlayer()
    {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        let hasMusicFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMusicFile
        var playingItemQueue = [AVPlayerItem]()
        if connectToNKU == false && hasMusicFile == false
        {
            let bgm = NSBundle.mainBundle().pathForResource("bgm", ofType: "wav")
            let bgmURL = NSURL(fileURLWithPath: bgm!)
            let playItem = AVPlayerItem(URL: bgmURL)
            let playItem2 = AVPlayerItem(URL: bgmURL)
            playingItemQueue.append(playItem)
            playingItemQueue.append(playItem2)
        }
        else
        {
            for index in 0...(numOfMusicFile! - 1)
            {
                let shiftIndex = (currentPlayingIndex! + index) % numOfMusicFile!
                let pathComponent = (musicPlayingQueue[shiftIndex].name!) + (musicPlayingQueue[shiftIndex].id!) + ".mp3"
                let fileURL = FileManager.pathOfDocumentDirectory().URLByAppendingPathComponent(pathComponent)
                let playItem = AVPlayerItem(URL: fileURL)
                playingItemQueue.append(playItem)
            }
        }
        audioPlayer = AVQueuePlayer(items: playingItemQueue)
        startObserving()
    }
    
    func startObserving()
    {
        if isObserving == false
        {
            isObserving = true
            audioPlayer?.addObserver(self, forKeyPath: "status", options: .New, context:nil)
            audioPlayer?.addObserver(self, forKeyPath: "currentItem", options: .Old, context:nil)
        }
    }
    
    func stopObserving()
    {
        if isObserving == true
        {
            isObserving = false
            audioPlayer?.removeObserver(self, forKeyPath: "status", context:nil)
            audioPlayer?.removeObserver(self, forKeyPath: "currentItem", context:nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if audioPlayer?.status == .ReadyToPlay {
                audioPlayer!.play()
                playingStatus = .Playing
            }
            else
            {
                let errorMessage = audioPlayer?.status == .Failed ? audioPlayer?.error?.localizedDescription : "Unknown"
                print(errorMessage!)
            }
        } else if keyPath == "currentItem" {
            currentPlayingIndex = (currentPlayingIndex! + 1) % numOfMusicFile!
            if let itemRemoved = change?[NSKeyValueChangeOldKey] as? AVPlayerItem {
                stopObserving()
                audioPlayer!.removeItem(itemRemoved)
                itemRemoved.seekToTime(kCMTimeZero)
                audioPlayer!.insertItem(itemRemoved, afterItem: audioPlayer?.items().last)
                startObserving()
            }

        }
    }
    
    func deInitPlayer()
    {
        audioPlayer?.pause()
        stopObserving()
        audioPlayer = nil
        playingStatus = .Stop
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl
        {
            switch event!.subtype {
            case .RemoteControlPlay:
                audioPlayer?.play()
                startObserving()
                playingStatus = .Playing
            case .RemoteControlPause:
                audioPlayer?.pause()
                stopObserving()
                playingStatus = .Pause
            case .RemoteControlNextTrack:
                audioPlayer?.advanceToNextItem()
            case .RemoteControlPreviousTrack:
                audioPlayer?.seekToTime(CMTimeMake(0,1))
            default: break
            }
        }
    }
    
}


extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        toggleSlidePanel()
    }
}


