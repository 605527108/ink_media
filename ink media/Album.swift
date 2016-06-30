//
//  Album.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/12/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class Album : NSObject
{
    internal var name: String?
    internal var artist: String?
    internal var sounds: [Music]?
    
    internal init(name: String, artist: String) {
        self.name = name
        self.artist = artist
    }
    
    internal var thumbnailURL: String?
    
    internal var thumbnailData: NSData?
    
    internal init(name: String, artist: String, sounds: [Music],thumbnailURL: String) {
        self.name = name
        self.artist = artist
        self.sounds = sounds
        self.thumbnailURL = thumbnailURL
    }
    class func allAlbums() -> [Album]
    {
        return [Album(name:"后会无期",artist:"邓紫棋",sounds:[Music(name:"后会无期",id:"98060"), ],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/G/G/001axO7402nnGG.jpg"),
        Album(name:"偶尔",artist:"邓紫棋",sounds:[Music(name:"偶尔",id:"98091"), ],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/A/z/003oLIsS1rbdAz.jpg"),
        
        Album(name:"Xposed",artist:"邓紫棋",sounds:[Music(name:"不存在的存在",id:"98237"), ],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/y/I/002YFufr4bXZyI.jpg"),
        
        Album(name:"The Best Of G.E.M.2008-2012",artist:"邓紫棋",sounds:[Music(name:"Sleeping Beauty",id:"98394"), ],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/2/C/000mmrVb4fam2C.jpg"),
        
        Album(name:"My Secret",artist:"邓紫棋",sounds:[ Music(name:"Get Over You",id:"94643"),],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/X/Q/004eR9Sh3CWjXQ.jpg"),
        
        Album(name:"G.E.M",artist:"邓紫棋",sounds:[Music(name:"回忆的沙漏",id:"83284"),
        Music(name:"睡公主",id:"83285"),
        Music(name:"爱现在的我",id:"83300"),
        Music(name:"等一个他",id:"83286"),
        Music(name:"Where did you go",id:"83283"), ],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/k/s/000cFPKx3ZGzks.jpg"),
        
        Album(name:"18 Plus",artist:"邓紫棋",sounds:[ Music(name:"A.I.N.Y.",id:"88270"),
        Music(name:"塞纳河",id:"88273"),
        Music(name:"G.E.M.(Get Everybody Moving)",id:"88275"),
        Music(name:"18",id:"88276"),
        Music(name:"Where Did You Go 2.0(Sam Vahda Remix)",id:"88277"),
        Music(name:"我不懂爱",id:"88272"),
        Music(name:"Mascara",id:"88271"),
        Music(name:"Game Over",id:"88268"),
        Music(name:"意式恋爱",id:"88274"),
        Music(name:"Mascara(Glossy Version)",id:"88278"),
        Music(name:"All About U",id:"88267"),
        Music(name:"想讲你知",id:"88269"),],thumbnailURL:"http://imgcache.qq.com/music/photo/mid_album_300/p/X/000a7bct08RqpX.jpg"),]
    }
}