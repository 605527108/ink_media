//
//  MovieFetcher.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/5/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class MovieFetcher
{
    internal let searchText: String
    internal let searchType: SearchType
    internal var networkUtilityForMovie: NetworkUtility
    
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
        self.networkUtilityForMovie = NetworkUtility(pageType: .movie)
        
        if searchType == .index
        {
            let movieURL = NSURL(string: "http://222.30.44.37/")
            networkUtilityForMovie.HTTPGETRequestForURL(movieURL!)
        }
        else if searchType == .name
        {
            let movieURL = NSURL(string: "http://222.30.44.37/filmclass.php?action=search")
            let params = ["searchtype":"name","searchstring":searchText]
            networkUtilityForMovie.HTTPPOSTRequestForURL(movieURL!, parameters: params)
        }
        else if searchType == .detail
        {
            let movieURL = NSURL(string: "http://222.30.44.37/filminfo/filminfo_"+searchText+".htm")
            networkUtilityForMovie.HTTPGETRequestForURL(movieURL!)
        }
        else if searchType == .link
        {
            let movieURL = NSURL(string: "http://222.30.44.37/joyview/joyview_getip.php?version=1.2.0.3&filmid="+searchText+"&getnum=2&d_from=8&d_to=8&port=8080")
            networkUtilityForMovie.HTTPGETRequestForURL(movieURL!)
        }
        else if searchType == .thumbnailOnline
        {
            let movieURL = NSURL(string: "http://222.30.44.37/posterimgs/big/" + searchText + ".jpg")
            networkUtilityForMovie.HTTPGETRequestForURL(movieURL!)
        }
        else if searchType == .thumbnailOffline
        {
            let movieURL = NSURL(string: "http://inankai.cn/ios/movieimage/" + searchText + ".jpg")
            networkUtilityForMovie.HTTPGETRequestForURL(movieURL!)
        }
    }
    
    internal func fetchMovieDetail(handler:(Movie?)-> Void)
    {
        let movie = Movie(name: "")
        var links = [String]()
        self.networkUtilityForMovie.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
                print(["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    if let movieString = String.init(data: rawData!, encoding: gbkEncoding)
                    {
                    var pattern = "([^\n ]*)：[^：]*#016A9F.>([^\n]*)</s"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                        for index in 0...(match.count-1) {
                            let keyRange = match[index].rangeAtIndex(1)
                            let valueRange = match[index].rangeAtIndex(2)
                            movie.info[(movieString as NSString).substringWithRange(keyRange)] = (movieString as NSString).substringWithRange(valueRange)
                        }
                    }
                    catch {
                        print("Regular expression error")
                    }
                    
                    pattern = "justify.>([^\n]*)</td"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                        let resultRange = match[0].rangeAtIndex(1)
                        movie.content = (movieString as NSString).substringWithRange(resultRange)
                        }
                    catch {
                        print("Regular expression error")
                    }
                    
                    pattern = "(◎简　　介|\\r|&nbsp;|　|<br>|&#8943|)"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let resultStr = regex.stringByReplacingMatchesInString(movie.content!, options: NSMatchingOptions(rawValue:0), range: NSMakeRange(0, (movie.content!.characters.count)), withTemplate: "")
                        movie.content = resultStr
                    }
                    catch {
                        print("Regular expression error")
                    }
                    
                    pattern = "joyview://([^\n]*)\" t"
                    do {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                        for index in 0...(match.count-1) {
                            let resultRange = match[index].rangeAtIndex(1)
                            let resultStr = (movieString as NSString).substringWithRange(resultRange)
                            let decodedData = NSData(base64EncodedString: resultStr, options:.IgnoreUnknownCharacters)
                            let fileName = String(data: decodedData!, encoding: gbkEncoding)
                            links.append(fileName!)
                        }
                    }
                    catch {
                        print("Regular expression error")
                    }
                    
                    pattern = "\\|([^\\|]*)\\|([^\\|]*)\\|[^\\|]*\\|"

                    for link in links
                    {
                        do {
                            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                            let match = regex.matchesInString(link, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, link.characters.count))
                            var resultRange = match[0].rangeAtIndex(1)
                            let fileID = (link as NSString).substringWithRange(resultRange)
                            resultRange = match[0].rangeAtIndex(2)
                            let fileName = (link as NSString).substringWithRange(resultRange)
                            movie.videos.append(Video(name: fileName, id: fileID))
                        }
                        catch {
                            print("Regular expression error")
                        }
                    }
                    }
                }
            }
            handler(movie)
        })
    }
    
    internal func fetchMovieURL(fileName: String,handler:(String?)-> Void)
    {
        var movieDownloadURL: String?
        
        self.networkUtilityForMovie.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
                print(["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    if let movieString = String(data: rawData!, encoding: gbkEncoding)
                    {
                    let pattern = "(http[^\\|]*)\\|"
                    do
                    {
                        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                        let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                        let resultRange = match[0].rangeAtIndex(1)
                        let resultStr = (movieString as NSString).substringWithRange(resultRange)
                        movieDownloadURL = resultStr+"/" + fileName.stringByAddingPercentEscapesUsingEncoding(gbkEncoding)!
                    }
                    catch {
                        print("Regular expression error")
                    }
                    }
                }
            }
            handler(movieDownloadURL)
        })
    }
    
    internal func fetchMultipleMovies(handler:(Array<Movie>)-> Void) {
        var movies = [Movie]()
        self.networkUtilityForMovie.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
                print(["errorInfo":HTTPError!.localizedDescription])
            }
            else
            {
                if (rawData != nil)
                {
                    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    if let movieString = String(data: rawData!, encoding: gbkEncoding)
                    {
                        var pattern = "#016A9F.>([^\n]*)</s"
                        do {
                            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                            let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                            var movieArrayCapacity = 24
                            if match.count < movieArrayCapacity
                            {
                                movieArrayCapacity = match.count
                            }
                            if movieArrayCapacity > 0
                            {
                                for index in 0...(movieArrayCapacity-1) {
                                    let result = match[index].rangeAtIndex(1)
                                    let movie = Movie(name: (movieString as NSString).substringWithRange(result))
                                    movies.append(movie)
                                }
                            }
                        }
                        catch {
                            print("Regular expression error")
                        }
                        if(movies.count > 0)
                        {
                            pattern = "\\(\\'(\\d+)\\'\\)."
                            do {
                                let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
                                let match = regex.matchesInString(movieString, options:NSMatchingOptions(rawValue:0), range: NSMakeRange(0, movieString.characters.count))
                                let movieArrayCapacity = match.count < movies.count ? match.count : movies.count
                                if movieArrayCapacity > 0
                                {
                                    for index in 0...(movieArrayCapacity-1)
                                    {
                                        let movieId = match[index].rangeAtIndex(1)
                                        movies[index].id = (movieString as NSString).substringWithRange(movieId)
                                    }
                                }

                            }
                            catch
                            {
                                print("Regular expression error")
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieFetcher", object: nil, userInfo: ["errorInfo":"Sorry啦没找到"])
                        }
                    }
                }
            }
            handler(movies)
        })
    }
    
    internal func fetchMovieThumbnail(handler:(NSData?)-> Void) {
        self.networkUtilityForMovie.sendDataRequest({ (rawData, HTTPError) in
            if (HTTPError != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationFromMovieFetcher", object: nil, userInfo: ["errorInfo":HTTPError!.localizedDescription])
            }
            handler(rawData)
        })
    }
}