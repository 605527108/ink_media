//
//  Movie.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/5/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//  Sorry for the names of var...

import Foundation

class Movie : NSObject
{
    internal var name: String? //movie's display name on webpage
    internal var id : String? //movie's display id on webpage's url
    internal var info = Dictionary<String, String>() //movie's info on webpage

    internal var videos = [Video]() //movie's filename and fileID in Joylink
    internal var content :String? //movie's plot detail
    
    internal init(name: String, id: String)
    {
        self.name = name
        self.id = id
    }
    
    internal convenience init(name: String) {
        self.init(name: name,id: "")
    }
        
    internal var thumbnailData: NSData?
    
    internal init(name: String,id: String,info:Dictionary<String, String>,content:String)
    {
        self.name = name
        self.id = id
        self.info = info
        self.content = content
    }
    class func allMovies() -> [Movie]
    {
        return [Movie(name:"魔宫魅影",id:"2141",info:[ "观看次数":"57",
            "制片国家/地区":"中国",
            "主演":"林心如  杨祐宁  任达华  黄幻  景岗山  林江国  孟瑶  张子枫  黄磊  李菁",
            "语言":"汉语普通话",
            "上映日期":"2016-04-29",
            "片长":"104分钟",
            "导演":"叶伟民",
            "类型":"惊悚"],content:"故事发生在三十年代的上海，顾维邦（杨佑宁饰）是一位名不见经传的小导演，一次偶然中，他遇见了名为梦思凡（林心如饰）的女明星，两人一拍即合，决定拍摄一部爱情惊悚电影，顾维邦为其取名为《夜半歌声》。一切都进行的很顺利，演员们纷纷入驻剧组，只等待开拍。顾维邦将拍摄地点选在了丽宫电影院，虽然很多人告诫他这里曾经发生过耸人听闻的灵异事件，不宜久留，但固执的顾维邦毫不在意。果不其然，没过多久，剧组里就接连发生了许多怪事，直到扮演男主角的演员离奇死亡，众人才发现事情已经如此严重。顾维邦的未婚妻麦丽斯（黄幻饰）来到剧组想要调查事件的真相，却牵扯出了一段顾维邦和梦思凡之间的尘封旧事。"),
                Movie(name:"判我有罪",id:"2140",info:["观看次数":"41",
                    "制片国家/地区":"中国大陆",
                    "主演":"李昕芸  吴镇宇  戴立忍  田小洁  李至正",
                    "语言":"汉语普通话",
                    "上映日期":"2016-05-06",
                    "片长":"102分钟",
                    "导演":"孙亮",
                    "类型":"悬疑", ],content:"美艳忧郁的女医生冯雪辉（李昕芸饰）对男性有种致命的吸引力，但她的丈夫方文楠（吴镇宇饰）却以冷暴力相待，两人之间似有深深隐情，他们既是仇人又是同谋。突然医院发生了一起惨烈的坠楼命案，由此牵出一场围绕金钱与欲望的黑幕，仿佛漩涡注定改变所有人——不得志的颓废刑警张越（田小洁饰）视此案为事业翻身的最后机会而穷追不舍，却被冯雪辉利用引向她的目的；自负到病态的幕后黑手副院长康富荣（戴立忍饰）早早设计圈套诱捕冯雪辉为替罪羊；暗恋冯雪辉的英俊正直的蒋力航（李至正饰）其实是手握核心证据的人，但他被爱情深深伤害并亲手将冯雪辉投入监狱——漩涡中心里这个美艳的女人，她到底要什么？她为深藏一个不伦的秘密，她愿意付出任何代价，并誓将挡路的男人们击败，她的武器除了心计还有美丽的身体。"),
                Movie(name:"穿条纹睡衣的男孩",id:"2139",info:["观看次数":"32",
                    "制片国家/地区":"英国/美国",
                    "主演":"阿沙·巴特菲尔德  维拉·法梅加  大卫·休里斯  鲁伯特·弗兰德",
                    "语言":"英语",
                    "上映日期":"2008-11-28",
                    "片长":"94分钟",
                    "导演":"马克·赫曼",
                    "类型":"剧情", ],content:"改编自同名畅销小说，该片透过一个9岁德国小男孩的眼睛来审视二战中德国纳粹集中营，最终以震撼人心的结局感动千万观众。本片的故事发生在上个世纪四十年代，影片的主人公是一个德国的小男孩布鲁诺，1943年时他只有9岁。对于一个9岁的孩子来说，他眼中的世界依然是那样的简单和有趣。而人世间的不幸和苦楚也远非他可以理解的内容，但由于他的父亲是一名军官，在那个时代下注定了他的人生的苦旅。"),
                Movie(name:"少年时代",id:"2138",info:["版本":"bd",
                    "观看次数":"143",
                    "制片国家/地区":"美国",
                    "主演":"艾拉·科尔特兰  艾拉·科尔特兰",
                    "语言":"英语",
                    "上映日期":"2014-07-18",
                    "片长":"166分钟",
                    "导演":"理查德·林克莱特",
                    "类型":"剧情", ],content:"本片讲述一个男孩从6岁到18岁的成长历程,导演理查德·林克莱特花了12年时间来完成这部作品。它仔细描画了孩子的成长过程,及其父母亲各个方面的变化,可以让观众细致入微地体会岁月流逝的痕迹。为了不打扰主演艾拉·萨尔蒙的正常生活,拍摄均在他暑假期间的简短时间内完成。"),
                Movie(name:"失眠症",id:"2137",info:[ "版本":"bd",
                    "观看次数":"89",
                    "制片国家/地区":"美国",
                    "主演":"阿尔·帕西诺  马丁·唐文",
                    "语言":"英语",
                    "上映日期":"2002-01-01",
                    "片长":"118分钟",
                    "导演":"克里斯托弗·诺兰",
                    "类型":"悬疑",],content:"威尔·多莫（艾尔·帕西诺饰）是一个老练的洛杉矶警察局探员。他受命与搭档哈普到一个偏远的阿拉斯加小镇，去调查一个关于17岁少女被谋杀的案件。这是个地理环境很特殊的地区。这里永远是白昼，太阳永远不落，没有黑夜。多莫和哈普找到了本案的第一嫌疑人——隐居小说家沃特·芬茨（罗宾·威廉斯饰）。他们跟踪芬茨来到了礁石林立、雾气弥漫的海滩，而芬茨却突然消失在了迷雾中。正当芬茨逃离多莫的视线时，一声枪响，哈普到在了血泊中。怀着对同伴遇害的内疚以及对案件的责任感，多莫被迫加入了与老谋深算的芬茨之间的猫捉老鼠的心理游戏中。随着案情的深入，多莫不得不和一个当地警察（希拉里·斯万克饰）合作调查，这个人虽身份不明但机敏过人。然而他不知道，这一切都在芬茨的操作之中。也许是由于无法摆脱这种在黑夜出太阳的异常环境的困扰，又或是因为多莫自己的错误判断，这名患有严重失眠症的探员的精神状态正在受到前所未有的打击……"),
                Movie(name:"罗拉快跑",id:"2136",info:["版本":"DVD",
                    "观看次数":"87",
                    "制片国家/地区":"德国",
                    "主演":"弗兰卡·波坦特/莫里兹·布雷多/约阿希姆·科尔/海诺·弗兹/莫妮卡·布雷多",
                    "语言":"德语",
                    "上映日期":"1998-08-20",
                    "片长":"80分钟",
                    "导演":"汤姆·提克威",
                    "类型":"爱情", ],content:"一个女人如何拼命尽力的抢救她的爱人——一部令人屏息、兴奋的影片，爱欲生死将完全改观……你只有二十分钟筹出十万马克，并需狂奔穿梭于城市中拯救你的爱人。这个女孩凭着她的热情打破环绕周围的固定规则及世界存在的既有标准。如果说爱的力量可以移山，那么她真的可以。柏林，夏季某日，罗拉和曼尼是一对20出头的年轻恋人。曼尼是个不务正业的小混混，有一天他惹出一个天大的麻烦，竟然把走私得来的10万马克赃款弄丢了！而且他的老大20分钟之后就要来拿回这笔钱。懦弱的曼尼只好向罗拉求救，一个错误的决定可能造成可怕的后果。就只有二十分钟，钱到底在哪里，如何救命？罗拉开始快跑！罗拉快跑……为自己而跑，为曼尼而跑，为爱情而跑……《罗拉快跑》中的三段开场，都是从红色电话的特写开始，她接到曼尼自暴自弃的电话：“你老说爱是万能的，爱能在20分钟内变出十万元吗？”听完，就下定决心要帮助自己的男友。电话一挂完她立刻行动，跑过母亲身旁，技巧性的转场，画面一拉变成动画片，罗拉快跑下楼梯，经过喋喋不休的邻居，以及他那只凶狠的狗旁边。镜头拉回现实世界，罗拉跑出门外伫立在柏林的大街上，开始了她的这段快跑旅程。前两段的结局都非常的戏剧性，但导演独到的编导功力让第三段的结局出现一个大逆转的局面……"),
                Movie(name:"蓝丝绒",id:"2135",info:["版本":"DVD",
                    "观看次数":"179",
                    "制片国家/地区":"美国",
                    "主演":"伊莎贝拉·罗西里尼/凯尔·麦克拉克伦/丹尼斯·霍珀/劳拉·邓恩/霍普·兰格",
                    "语言":"英语",
                    "上映日期":"1986-09-19",
                    "片长":"120分钟",
                    "导演":"大卫·林奇",
                    "类型":"惊悚", ],content:"大学生杰弗里回故乡小镇照料患病父亲,回乡途中他意外发现一只人耳。警察威廉斯决定将此案彻查。杰弗里认识了威廉斯的女儿桑迪,二人相爱。桑迪告诉杰弗里案子可能与夜总会歌女有关。杰弗里在夜总会被歌女的美貌和气质所吸引,晚上设法来到她家,偷窥到歌女正被一个叫弗兰克的男人残忍地折磨着。弗兰克是无恶不作的黑道头子,绑架、贩毒、杀人,并且和警长狼狈为奸。弗兰克有性虐待癖,每糟蹋一个人就要在其嘴里塞上一块蓝色丝绒,或从身上割下一样东西留作“纪念”。不谙世事的杰弗里这才知道,在自己生活的圈子外,这个典型的美国小镇里,还有如此黑暗的一面,他发现正自己慢慢陷入一个充满谋杀、变态的离奇世界……"),
                Movie(name:"校园疯骚史之舞动青春",id:"2134",info:["版本":"DVD",
                    "观看次数":"115",
                    "制片国家/地区":"中国",
                    "主演":"彭禺厶/朱佳希",
                    "语言":"普通话",
                    "上映日期":"2015-04-28",
                    "片长":"97分钟",
                    "导演":"焦洋",
                    "类型":"喜剧", ],content:"学校动漫社团里的杨小伟（彭禺厶饰），是一个长相抱歉，成绩垫底，行动力差的技术宅男。在大学里所学的是计算机专业，打游戏是他唯一的专长。宿舍里有几个和他专业相同，爱好一致的废柴伙伴。一天，杨小伟和伙伴们像往常一样在校园里发着游戏社的宣传单，此时转校而来的女神级气质美女程诺（朱佳希饰）惊艳的走进校园，也走进了杨小伟的心里。随着程诺的到来，原本平静的学校，激起了层层涟漪。")]
    }
}