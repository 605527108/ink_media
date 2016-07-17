//
//  Cartoon.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/10/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import Foundation

class Cartoon: NSObject {
    internal var name: String?
    internal var id: String?
    internal var info = Dictionary<String, String>()
    
    internal var videos = [Video]()
    
    internal var thumbnailURL: String?
    
    internal var thumbnailData: NSData?
        
    internal init(name: String, id: String)
    {
        self.name = name
        self.id = id
    }
    
    internal convenience init(name: String) {
        self.init(name: name,id: "")
    }
    
    internal init(name:String,id:String,info:Dictionary<String, String>)
    {
        self.name = name
        self.id = id
        self.info = info
    }
    
    class func allCartoons() -> [Cartoon]
    {
        return [Cartoon(name:"Re：从零开始的异世界生活",id:"1557",info:[ "类型":"1",
            "当前集数":"12",
            "字幕组":"EMD",
            "更新时间":"2016-06-22 17:33:26",
            "下载量":"856",
            "当前状态":"连载中",
            "本周下载量":"63",
            "评论数":"4",]),
                
                Cartoon(name:"超时空要塞Δ",id:"1551",info:["类型":"1",
                    "当前集数":"12",
                    "字幕组":"NEO·QSW",
                    "更新时间":"2016-06-22 17:32:36",
                    "下载量":"342",
                    "当前状态":"连载中",
                    "本周下载量":"22",
                    "评论数":"3", ]),
                
                Cartoon(name:"鬼牌游戏",id:"1550",info:[ "类型":"1",
                    "当前集数":"11",
                    "字幕组":"DMG",
                    "更新时间":"2016-06-22 17:32:09",
                    "下载量":"233",
                    "当前状态":"连载中",
                    "本周下载量":"21",
                    "评论数":"1",]),
                
                Cartoon(name:"文豪野犬",id:"1542",info:["类型":"1",
                    "当前集数":"11",
                    "字幕组":"极影字幕社",
                    "更新时间":"2016-06-22 17:30:25",
                    "下载量":"599",
                    "当前状态":"连载中",
                    "本周下载量":"24",
                    "评论数":"4", ]),
                
                Cartoon(name:"青春波纹",id:"1548",info:["类型":"1",
                    "当前集数":"11",
                    "字幕组":"DHR&amp;MakariHoshiyume",
                    "更新时间":"2016-06-22 17:30:12",
                    "下载量":"166",
                    "当前状态":"连载中",
                    "本周下载量":"22",
                    "评论数":"0", ]),
                
                Cartoon(name:"羁绊者",id:"1556",info:[ "类型":"1",
                    "当前集数":"11",
                    "字幕组":"KTXP",
                    "更新时间":"2016-06-22 17:29:40",
                    "下载量":"156",
                    "当前状态":"连载中",
                    "本周下载量":"47",
                    "评论数":"4",]),
                
                Cartoon(name:"JOJO的奇妙冒险 不灭钻石",id:"1549",info:[ "类型":"1",
                    "当前集数":"12",
                    "字幕组":"JOJO&amp;UHA-WING&amp;HKACG&amp;Kamigami",
                    "更新时间":"2016-06-20 19:00:45",
                    "下载量":"367",
                    "当前状态":"连载中",
                    "本周下载量":"32",
                    "评论数":"3",]),
                
                Cartoon(name:"魔奇少年 辛巴达的冒险",id:"1553",info:["类型":"1",
                    "当前集数":"10",
                    "字幕组":"KTXP",
                    "更新时间":"2016-06-20 19:00:37",
                    "下载量":"135",
                    "当前状态":"连载中",
                    "本周下载量":"25",
                    "评论数":"2", ])]
    }
}