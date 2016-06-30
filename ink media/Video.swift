//
//  Video.swift
//  ink media
//
//  Created by Syn Ceokhou on 6/24/16.
//  Copyright © 2016 iNankai. All rights reserved.
//

import Foundation

class Video: NSObject
{
    internal var name: String?
    internal var id: String?
    internal var url: String?
    internal var downloaded: Bool?
    
    
    internal init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
}
