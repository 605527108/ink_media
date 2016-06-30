//
//  CartoonFetcher.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/10/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class CartoonFetcher
{
    internal let searchText: String
    internal let searchType: SearchType
    internal var networkUtilityForCartoon: NetworkUtility
    
    internal enum SearchType {
        case name
        case index
        case detail
        case link
        case thumbnailOnline
        case thumbnailOffline
    }
    
    internal init(searchText: String, searchType: SearchType = .name)
    {
        self.searchText = searchText
        self.searchType = searchType
        self.networkUtilityForCartoon = NetworkUtility(pageType: .cartoon)
        
        if searchType == .index
        {
            let cartoonURL = NSURL(string: "http://12club.nankai.edu.cn/programs?category_id=1")
            networkUtilityForCartoon.HTTPGETRequestForURL(cartoonURL!)
        }
        else if searchType == .name
        {
            let cartoonURL = NSURL(string: "http://12club.nankai.edu.cn/search")
            let params = ["authenticity_token":"2zLKdHp3Y4E6aU0GIfDxzFR+AC3SysAiKR22M5k8M90=","keyword":searchText]
            networkUtilityForCartoon.HTTPPOSTRequestForURL(cartoonURL!, parameters: params)
        }
        else if searchType == .detail
        {
            let cartoonURL = NSURL(string: "http://12club.nankai.edu.cn/programs/"+searchText)
            networkUtilityForCartoon.HTTPGETRequestForURL(cartoonURL!)
        }
        else if searchType == .link
        {
            let cartoonURL = NSURL(string: "http://12club.nankai.edu.cn/online_video/"+searchText+"?start=0")
            networkUtilityForCartoon.HTTPGETRequestForURL(cartoonURL!)
        }
        else if searchType == .thumbnailOnline
        {
            let cartoonURL = NSURL(string: "http://12club.nankai.edu.cn/upload/images/"+searchText)
            networkUtilityForCartoon.HTTPGETRequestForURL(cartoonURL!)
        }
        else if searchType == .thumbnailOffline
        {
            let cartoonURL = NSURL(string: "http://inankai.cn/ios/cartoonimage/"+searchText+".jpg")
            networkUtilityForCartoon.HTTPGETRequestForURL(cartoonURL!)
        }
    }
    
    internal func fetchMultipleCartoons(handler:(Array<Cartoon>)-> Void) {
        var cartoons = [Cartoon]()
        self.networkUtilityForCartoon.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    if let cartoonString = String(data: rawData!, encoding: NSUTF8StringEncoding)
                    {
                        var pattern = "programs/([\\d]*).*=\"([^\"]*)"
                        do {
                            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                            let match = regex.matchesInString(cartoonString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, cartoonString.characters.count))
                            let cartoonArrayCapacity = match.count
                            if cartoonArrayCapacity > 0
                            {
                                for index in 0...(cartoonArrayCapacity-1) {
                                    var result = match[index].rangeAtIndex(1)
                                    let cartoonID = (cartoonString as NSString).substringWithRange(result)
                                    result = match[index].rangeAtIndex(2)
                                    let cartoonName = (cartoonString as NSString).substringWithRange(result)
                                    let cartoon = Cartoon(name: cartoonName, id: cartoonID)
                                    cartoons.append(cartoon)
                                }
                            }
                        }
                        catch {
                            print("Regular expression error")
                        }
                        if(cartoons.count > 0)
                        {
                            pattern = "original='/upload/images/([^']*)'"
                            do {
                                let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                                let match = regex.matchesInString(cartoonString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, cartoonString.characters.count))
                                let cartoonArrayCapacity = match.count < cartoons.count ? match.count : cartoons.count
                                if cartoonArrayCapacity > 0
                                {
                                    for index in 0...(cartoonArrayCapacity-1) {
                                        let result = match[index].rangeAtIndex(1)
                                        let thumbnailURL = (cartoonString as NSString).substringWithRange(result)
                                        cartoons[index].thumbnailURL = thumbnailURL
                                    }
                                }
                            }
                            catch {
                                print("Regular expression error")
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo:["errorInfo":"Sorry啦没找到"])
                        }
                    }
                }
            }
            handler(cartoons)
        })
    }
    
    internal func fetchCartoonDetail(handler:(Cartoon?)-> Void) {
        let cartoon = Cartoon(name: "")
        self.networkUtilityForCartoon.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    if let cartoonString = String(data: rawData!, encoding: NSUTF8StringEncoding)
                    {
                    var pattern = "key\'>([^:key]*):.*val\'>([^<]*)<"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(cartoonString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, cartoonString.characters.count))
                        let cartoonArrayCapacity = match.count
                        if cartoonArrayCapacity > 0
                        {
                            for index in 0...(cartoonArrayCapacity-1) {
                                let keyRange = match[index].rangeAtIndex(1)
                                let valueRange = match[index].rangeAtIndex(2)
                                let key = (cartoonString as NSString).substringWithRange(keyRange)
                                let value = (cartoonString as NSString).substringWithRange(valueRange)
                                cartoon.info[key] = value
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object:nil, userInfo: ["errorInfo":"Regular expression error"])
                        }
                    }
                    catch {
                        print("Regular expression error")
                    }
                    
                    pattern = "value=\'([^\']*)\'.*次\'>([^<]*)<"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(cartoonString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, cartoonString.characters.count))
                        let cartoonArrayCapacity = match.count
                        if cartoonArrayCapacity > 0
                        {
                            for index in 0...(cartoonArrayCapacity-1) {
                                let keyRange = match[index].rangeAtIndex(2)
                                let valueRange = match[index].rangeAtIndex(1)
                                let fileName = (cartoonString as NSString).substringWithRange(keyRange)
                                let fileID = (cartoonString as NSString).substringWithRange(valueRange)
                                cartoon.videos.append(Video(name: fileName, id: fileID))
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo:["errorInfo":"该漫画不支持播放"])
                        }
                    }
                    catch {
                        print("Regular expression error")
                    }
                    }
                }
            }
            handler(cartoon)
        })
    }
    
    internal func fetchCartoonURL(handler:(String?)-> Void) {
        self.networkUtilityForCartoon.sendDataRequestAndGetRedirectLocation({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            handler(rawData as? String)
        })
    }
    
    internal func fetchCartoonThumbnail(handler:(NSData?)-> Void) {
        self.networkUtilityForCartoon.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromCartoonFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            handler(rawData)
        })
    }
}