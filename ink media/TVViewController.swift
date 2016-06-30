//
//  TVViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/9/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TVViewController: UIViewController {

    var videoURL: NSURL? {
        didSet{
            if connectToIPv6!
            {
                stopVideo()
                playVideo()
            }
            else
            {
                errorAlert("请连接有IPv6的Wi-Fi")
            }
        }
    }
    let connectToIPv6 = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToIPv6
    var error: Bool = false
    var isObserving = false
    let tvWidth = UIScreen.mainScreen().bounds.width
    let tvHeight = CGFloat(Double(UIScreen.mainScreen().bounds.width)/16*9)
    var scrollView: UIScrollView?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerView: UIView?
    var currentlyPlayingButtonTag: Int?
    
    let urlLookUpTable = [
        "btv1hd",
        "hunanhd",
        "cctv1hd",
        
        "zjhd",
        "chchd",
        "jshd",
        
        "cctv5phd",
        "dfhd",
        "szhd",
        
        "cctv8hd",
        "cctv5hd",
        "tjhd",
        
        
        "btv6hd",
        "cctv3hd",
        "cctv6hd"
    ]
    
    func changChannel(sender: UIButton) {
        videoURL = NSURL(string: "http://tv6.byr.cn/hls/" + sender.currentTitle! + ".m3u8")
        if let oldTag = currentlyPlayingButtonTag
        {
            let oldButton = scrollView?.viewWithTag(oldTag) as! UIButton
            oldButton.setBackgroundImage(UIImage(named: urlLookUpTable[oldTag - 1000]), forState: .Normal)
        }
        sender.setBackgroundImage(UIImage(named: sender.currentTitle! + "_Highlighted"), forState: .Normal)
        currentlyPlayingButtonTag = sender.tag
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopVideo()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IPv6电视"
        let tvMinY = self.navigationController?.navigationBar.frame.maxY
        let screenWidth = tvWidth
        let scrollViewHeight = self.view.frame.size.height - tvHeight - tvMinY!
        scrollView = UIScrollView(frame: CGRectMake(0,tvHeight + tvMinY!,screenWidth,scrollViewHeight))
        self.playerView = UIView(frame: CGRectMake(0,tvMinY!,self.tvWidth,self.tvHeight))
        self.view.addSubview(self.playerView!)
        var index = 0
        let buttonWidth = screenWidth/3
        for key in urlLookUpTable
        {
            
            let button = UIButton(type: UIButtonType.System)
            let buttonMinX = CGFloat(index%3) * buttonWidth
            let buttonMinY = CGFloat(index/3) * buttonWidth
            button.setTitle(key, forState: .Normal)
            button.setTitle(key, forState: .Highlighted)
            button.tintColor = UIColor.clearColor()
            button.frame = CGRectMake(buttonMinX, buttonMinY, buttonWidth, buttonWidth)
            button.setBackgroundImage(UIImage(named: key), forState: .Normal)
            button.addTarget(self, action: #selector(self.changChannel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = 1000 + index
            self.scrollView!.addSubview(button)
            index = index + 1
        }
        scrollView!.contentSize = CGSize(width: buttonWidth*3, height: buttonWidth*CGFloat(urlLookUpTable.count/3))
        scrollView?.bounces = false
        view.addSubview(scrollView!)
        let fullscreen_icon = UIImage(named: "icon_nav_fullscreen")
        let barButton = UIBarButtonItem(image: fullscreen_icon, style: .Plain, target: self, action: #selector(self.fullScreen))
        self.navigationItem.rightBarButtonItem = barButton
        videoURL = NSURL(string: "http://tv6.byr.cn/hls/cctv1hd.m3u8")
        let firstButton = scrollView?.viewWithTag(1002) as! UIButton
        firstButton.setBackgroundImage(UIImage(named: urlLookUpTable[2] + "_Highlighted"), forState: .Normal)
        currentlyPlayingButtonTag = 1002
    }
    
    func fullScreen()
    {
        if !(error)
        {
            stopVideo()
            let tvPlayerVC = TVPlayerController()
            tvPlayerVC.player = AVPlayer(URL: self.videoURL!)
            self.navigationController?.presentViewController(tvPlayerVC, animated: true, completion: nil)
        }
    }
    
    func stopVideo()
    {
        if(isObserving)
        {
            player?.removeObserver(self, forKeyPath: "status", context: nil)
            isObserving = false
        }
        self.player?.pause()
        dispatch_async(dispatch_get_main_queue())
        {
            if let layer = self.playerLayer
            {
                layer.removeFromSuperlayer()
            }
        }
        self.playerLayer = nil
        self.player = nil
    }
    
    func playVideo()
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        {
            self.player = AVPlayer(URL: self.videoURL!)
            self.player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue:0), context:nil)
            self.isObserving = true
            dispatch_async(dispatch_get_main_queue())
            {
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer!.frame = (self.playerView?.bounds)!
                self.playerView!.layer.addSublayer(self.playerLayer!)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status"
        {
            if player?.status == .ReadyToPlay {
                player!.play()
            }
            else
            {
                error = true
                let errorMessage = player?.status == .Failed ? player?.error?.localizedDescription : "Unknown"
                errorAlert(errorMessage!)
            }
        }
    }

    func errorAlert(errorMessage: String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "TV", message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
