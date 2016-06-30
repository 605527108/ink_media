//
//  NetworkUtility.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/8/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class NetworkUtility: NSObject, NSURLSessionTaskDelegate
{
    let TIME_OUT_INTERVAL = Double(10)
    
    internal enum PageType {
        case movie
        case cartoon
        case music
    }
    
    internal var URLRequest: NSMutableURLRequest?
    
    internal var pageType: PageType
    
    internal init(pageType :PageType)
    {
        self.pageType = pageType
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void)
    {
        completionHandler(nil)
    }
    
    internal func HTTPGETRequestForURL(url: NSURL)
    {
        URLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: TIME_OUT_INTERVAL)
        URLRequest!.HTTPMethod = "GET"
        URLRequest!.HTTPShouldHandleCookies = true
    }
    
    internal func HTTPPOSTRequestForURL(url: NSURL, parameters: [String:String])
    {
        URLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: TIME_OUT_INTERVAL)
        let HTTPBodyString = HTTPBodyWithParameters(parameters)
        if self.pageType == .movie
        {
            let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            URLRequest!.HTTPBody = HTTPBodyString.dataUsingEncoding(gbkEncoding)
        }
        else
        {
            URLRequest!.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        URLRequest!.HTTPMethod = "POST"
        URLRequest!.HTTPShouldHandleCookies = true
    }
    
    func HTTPBodyWithParameters(params: [String:String]) -> String {
        var paramsArray = [String]()
        for key in params.keys
        {
            let value = params[key]
            paramsArray.append(key + "=" + value!)
        }
        return paramsArray.joinWithSeparator("&")
    }
    
    internal func sendDataRequest(handler: (rawData: NSData?, HTTPError: NSError?)->Void)
    {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(URLRequest!) { (data, response, error) in
            if(error != nil)
            {
                handler(rawData: nil,HTTPError: error!);
            }
            else
            {
                let httpResponse = response as! NSHTTPURLResponse
                if(httpResponse.statusCode == 200)
                {
                    handler(rawData: data!, HTTPError: nil)
                }
                else
                {
                    let statusError = NSError(domain: "statusCodeNotEqualTo200", code: httpResponse.statusCode, userInfo: ["errorInfo":"statusCodeNotEqualTo200"])
                    handler(rawData: nil, HTTPError: statusError)
                }
            }
        }
        task.resume()
    }
    
    internal func sendDataRequestAndGetRedirectLocation(handler: (location: AnyObject?, HTTPError: NSError?)->Void)
    {
        let URLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: URLSessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithRequest(URLRequest!) { (data, response, error) in
            if(error != nil)
            {
                handler(location: nil,HTTPError: error!);
            }
            else
            {
                let HTTPURLResponse = response as! NSHTTPURLResponse
                if(HTTPURLResponse.statusCode == 302)
                {
                    let redirectLocation = HTTPURLResponse.allHeaderFields["Location"]
                    handler(location: redirectLocation, HTTPError: nil)
                }
                else
                {
                    let statusError = NSError(domain: "statusCodeNotEqualTo302", code: HTTPURLResponse.statusCode, userInfo: HTTPURLResponse.allHeaderFields)
                    print(self.URLRequest?.URL)
                    handler(location: nil, HTTPError: statusError)
                }
            }
        }
        task.resume()
    }
}