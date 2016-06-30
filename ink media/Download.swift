//
//  Download.swift
//  test
//
//  Created by Syn Ceokhou on 6/24/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class Download: NSObject {
    
    var indexPath: NSIndexPath
    var isDownloading = false
    var progress: Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    var resumeData: NSData?
    
    init(indexPath: NSIndexPath) {
        self.indexPath = indexPath
    }
}