//
//  SlidePanelViewController.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/19/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

protocol SlidePanelViewControllerDelegate {
    func tabSelected(tabName: String?)
    func currentlyPlayingMusic() -> Music?
    func playingOrStop() -> PlayingStatus
    func currentlyDisplayingVC() -> String
}

class SlidePanelViewController: UIViewController {
    
    var delegate: SlidePanelViewControllerDelegate?
    
    let tabs = ["光影传奇" ,"12Club动漫" ,"桃源音乐", "音乐播放器","IPv6电视","电影文件","动漫播放器"]
    let imageName = ["btn_slidebar_1","btn_slidebar_2","btn_slidebar_3","btn_slidebar_3","btn_slidebar_4","btn_slidebar_1","btn_slidebar_2"]
    @IBOutlet weak var tableView: UITableView!
    
    struct TableView {
        static let TabCellIdentifier = "TabCell"
        static let MusicPlayingCellIdentifier = "MusicPlayingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
}

extension SlidePanelViewController: UITableViewDataSource {
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        let hasMovieFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMovieFile
        let hasMusicFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMusicFile
        let hasCartoonFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasCartoonFile
        if connectToNKU == false && hasMovieFile == false && hasCartoonFile == false && hasMusicFile == false {
            return 4
        }
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        let hasMusicFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMusicFile
        if let music = delegate!.currentlyPlayingMusic() where tabs[indexPath.row] == "音乐播放器"
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableView.MusicPlayingCellIdentifier, forIndexPath: indexPath) as! MusicPlayingCell
            cell.musicPlayingButton.setTitle("", forState: .Normal)
            if delegate!.playingOrStop() == .Playing
            {
                cell.musicPlayingButton.setBackgroundImage(UIImage(named: "icon_play_active"), forState: .Normal)
                cell.isPlaying = true
            } else if delegate!.playingOrStop() == .Pause {
                cell.musicPlayingButton.setBackgroundImage(UIImage(named: "icon_play_normal"), forState: .Normal)
                cell.isPlaying = false
            }
            cell.musicPlayingInfo.text = music.name!
            if "音乐播放器" == delegate?.currentlyDisplayingVC()
            {
                cell.musicPlayingInfo.textColor = UIColor.redColor()
            }
            else
            {
                cell.musicPlayingInfo.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)

            }
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        else if connectToNKU == false && hasMusicFile == false && delegate!.playingOrStop() == .Stop && tabs[indexPath.row] == "音乐播放器"
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableView.MusicPlayingCellIdentifier, forIndexPath: indexPath) as! MusicPlayingCell
            cell.musicPlayingButton.setTitle("", forState: .Normal)
            cell.musicPlayingButton.setBackgroundImage(UIImage(named: "icon_play_normal"), forState: .Normal)
            cell.isPlaying = false
            cell.musicPlayingInfo.text = "南开大学校歌"
            cell.musicPlayingInfo.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.TabCellIdentifier, forIndexPath: indexPath) as! TabCell
        cell.tabNameLabel.text = tabs[indexPath.row]
        if cell.tabNameLabel.text == delegate?.currentlyDisplayingVC()
        {
            cell.tabNameLabel.textColor = UIColor.redColor()
            cell.tabImage.image = UIImage(named: (imageName[indexPath.row] + "_active"))
        }
        else
        {
            cell.tabNameLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
            cell.tabImage.image = UIImage(named: (imageName[indexPath.row] + "_normal"))
        }
        return cell
    }
    
}

extension SlidePanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let connectToNKU = (UIApplication.sharedApplication().delegate as? AppDelegate)?.connectToNKU
        let hasMusicFile = (UIApplication.sharedApplication().delegate as? AppDelegate)?.hasMusicFile
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? MusicPlayingCell
        {
            if connectToNKU == true || hasMusicFile == true
            {
                delegate?.tabSelected("音乐播放器")
            }
            else
            {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        else if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TabCell
        {
            let tabName = cell.tabNameLabel.text
            delegate?.tabSelected(tabName!)
        }
    }
    
}

class TabCell: UITableViewCell {
    
    @IBOutlet weak var tabNameLabel: UILabel!
    
    @IBOutlet weak var tabImage: UIImageView!
}


class MusicPlayingCell: UITableViewCell {
    var isPlaying: Bool?
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateMusicInfo(_:)), name: "PlayerReachEnd", object: nil)
    }
    
    func updateMusicInfo(notification: NSNotification)
    {
        if let music = notification.userInfo!["music"] as? Music
        {
            musicPlayingInfo.text = music.name! + music.id!
        }
    }
    
    @IBAction func toggleMusicPlaying(sender: UIButton) {
        if isPlaying! {
            sender.setBackgroundImage(UIImage(named: "icon_play_normal"), forState: .Normal)
            self.isPlaying = false
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMuiscFile", object: nil, userInfo: ["signal":"pause"])

        } else {
            sender.setBackgroundImage(UIImage(named: "icon_play_active"), forState: .Normal)
            self.isPlaying = true
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMuiscFile", object: nil, userInfo: ["signal":"play"])
        }
        
    }
    @IBOutlet weak var musicPlayingButton: UIButton!
    @IBOutlet weak var musicPlayingInfo: UILabel!
}
    
