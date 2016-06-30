//
//  MusicFetcher.swift
//  movie
//
//  Created by Syn Ceokhou on 6/12/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class MusicFetcher
{
    internal let searchText: String
    internal let searchType: SearchType
    internal var networkUtilityForMusic: NetworkUtility
    
    internal enum SearchType {
        case artist
        case album
        case music
        case thumbnail
        case thumbnailURL
    }
    
    
    internal init(searchText: String, searchType: SearchType = .album)
    {
        self.searchText = searchText
        self.searchType = searchType
        self.networkUtilityForMusic = NetworkUtility(pageType: .music)
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))

        if searchType == .artist
        {
            let artistInGBK = searchText.stringByAddingPercentEscapesUsingEncoding(gbkEncoding)
            let musicURL = NSURL(string: "http://music.nankai.edu.cn/albumlist.php?artist="+artistInGBK!)
            networkUtilityForMusic.HTTPGETRequestForURL(musicURL!)
        }
        else if searchType == .album
        {
            let albumInGBK = searchText.stringByAddingPercentEscapesUsingEncoding(gbkEncoding)
            let musicURL = NSURL(string: "http://music.nankai.edu.cn/albumlist.php")
            let params = ["searchtype":"album","searchstring":albumInGBK!]
            networkUtilityForMusic.HTTPPOSTRequestForURL(musicURL!, parameters: params)
        }
        else if searchType == .thumbnailURL
        {
            let encodingSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
            let musicURL = NSURL(string: "http://s.music.qq.com/fcgi-bin/music_search_new_platform?t=0&n=1&aggr=1&cr=1&loginUin=0&format=json&inCharset=GB2312&outCharset=utf-8&notice=0&platform=jqminiframe.json&needNewCode=0&p=1&catZhida=0&remoteplace=sizer.newclient.next_song&w=" + encodingSearchText!)
            networkUtilityForMusic.HTTPGETRequestForURL(musicURL!)
        }
        else if searchType == .thumbnail
        {
            let musicURL = NSURL(string: searchText)
            networkUtilityForMusic.HTTPGETRequestForURL(musicURL!)
        }
        else if searchType == .music
        {
            let musicURL = NSURL(string: "http://music.nankai.edu.cn/main.php?iframeID=layer_d_3_I&searchtype=album&"+searchText)
            networkUtilityForMusic.HTTPGETRequestForURL(musicURL!)
        }
    }
    
    
    internal func fetchMultipleAlbums(handler:(Array<Album>)-> Void)
    {
        var albums = [Album]()
        
        self.networkUtilityForMusic.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMusicFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    if let musicString = String.init(data: rawData!, encoding: gbkEncoding)
                    {
                        var pattern = ">([^<]*)<\\/a"
                        do
                        {
                            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                            let match = regex.matchesInString(musicString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, musicString.characters.count))
                            let albumNum = match.count
                            if albumNum > 0 {
                                for index in 0...(albumNum-1)
                                {
                                    let resultRange = match[index].rangeAtIndex(1)
                                    let albumName = (musicString as NSString).substringWithRange(resultRange)
                                    let album = Album(name: albumName, artist: "")
                                    albums.append(album)
                                }
                            }
                        }
                        catch {
                            print("Regular expression error")
                        }
                        if albums.count > 0
                        {
                            if (self.searchType == .artist)
                            {
                                let albumNum = albums.count
                                if albumNum > 0 {
                                    for index in 0...(albumNum-1)
                                    {
                                        albums[index].artist = self.searchText
                                    }
                                }
                            }
                            else
                            {
                                pattern = "itle=\'([^\\[]*) \\["
                                do
                                {
                                    let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                                    let match = regex.matchesInString(musicString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, musicString.characters.count))
                                    let albumNum = match.count < albums.count ? match.count : albums.count
                                    if albumNum > 0 {
                                        for index in 0...(albumNum-1)
                                        {
                                            let resultRange = match[index].rangeAtIndex(1)
                                            let artistName = (musicString as NSString).substringWithRange(resultRange)
                                            albums[index].artist = artistName
                                        }
                                    }
                                }
                                catch {
                                    print("Regular expression error")
                                }
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMusicFetcher", object: nil, userInfo: ["errorInfo":"Sorry啦没找到"])
                        }
                    }
                }
            }
            handler(albums)
        })
    }
    
    
    internal func fetchMultipleMusic(handler:(Array<Music>)-> Void)
    {
        var musicCollection = [Music]()
        
        self.networkUtilityForMusic.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMusicFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    if let musicString = String(data: rawData!, encoding: gbkEncoding)
                    {
                    let pattern = "编号:([^　]*).*green>([^<]*)<\\/f"
                    do
                    {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(musicString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, musicString.characters.count))
                        let fileNum = match.count
                        if fileNum > 0
                        {
                            for index in 0...(fileNum-1)
                            {
                                var resultRange = match[index].rangeAtIndex(2)
                                let musicName = (musicString as NSString).substringWithRange(resultRange)
                                resultRange = match[index].rangeAtIndex(1)
                                let musicID = (musicString as NSString).substringWithRange(resultRange)
                                let music = Music(name: musicName, id: musicID)
                                musicCollection.append(music)
                            }
                        }
                    }
                    catch {
                        print("Regular expression error")
                    }
                    }
                }
            }
            handler(musicCollection)
        })
    }
    
    internal func fetchAlbumThumbnailURL(handler:(String?)-> Void)
    {
        var thumbnailURL: String?
        
        self.networkUtilityForMusic.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMusicFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    if let musicString = String(data: rawData!, encoding: NSUTF8StringEncoding)
                    {
                    
                    let pattern = "\\|([^\\|]*)\\|[\\d]*\\|[\\d]*\""
                        do
                        {
                            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                            let match = regex.matchesInString(musicString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, musicString.characters.count))
                            if match.count > 0
                            {
                            let result = match[0].rangeAtIndex(1)
                            let resStr = (musicString as NSString).substringWithRange(result)
                            var resChar = resStr.characters
                            let lastCh = resChar.popLast()
                            let secondLastCh = resChar.popLast()
                            thumbnailURL = "http://imgcache.qq.com/music/photo/mid_album_300/\(secondLastCh!)/\(lastCh!)/\(resStr).jpg"
                            }
                        }
                        catch {
                            print("Regular expression error")
                        }
                    }
                }
            }
            handler(thumbnailURL)
        })
    }
    
    internal func fetchAlbumThumbnail(handler:(NSData?)-> Void) {
        self.networkUtilityForMusic.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromAlbumFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            handler(rawData)
        })
    }
    
}