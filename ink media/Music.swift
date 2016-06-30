//
//  Music.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/12/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class Music: NSObject {
    internal var name: String?
    internal var id: String?
    internal var url: String?
    internal var downloaded: Bool?
    
    internal init(name: String, id: String) {
        self.name = name
        self.id = id
        self.url = "http://music.nankai.edu.cn/download.php?id=" + id
    }

}