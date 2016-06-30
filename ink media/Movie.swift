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
                    "类型":"喜剧", ],content:"学校动漫社团里的杨小伟（彭禺厶饰），是一个长相抱歉，成绩垫底，行动力差的技术宅男。在大学里所学的是计算机专业，打游戏是他唯一的专长。宿舍里有几个和他专业相同，爱好一致的废柴伙伴。一天，杨小伟和伙伴们像往常一样在校园里发着游戏社的宣传单，此时转校而来的女神级气质美女程诺（朱佳希饰）惊艳的走进校园，也走进了杨小伟的心里。随着程诺的到来，原本平静的学校，激起了层层涟漪。"),
                
                Movie(name:"盗钥匙的方法",id:"2133",info:[ "版本":"BD",
                    "观看次数":"75",
                    "制片国家/地区":"日本",
                    "主演":"堺雅人 / 香川照之 / 广末凉子 / 荒川良良 / 森口瑶子",
                    "语言":"日语",
                    "上映日期":"2012-09-15",
                    "片长":"128分钟",
                    "导演":"内田贤治",
                    "类型":"喜剧",],content:"樱井（堺雅人）是一名红不起来的穷演员，某日他在澡堂偶遇一名男子在自己眼前滑倒，头部受到重击，于是一时兴起偷换了他的衣柜钥匙，企图与该男子互换身份。但这名男子的真实身份却是无人见过的杀手近藤（香川照之）。于是，更换了身份的樱井被牵扯进了关系到大笔资金的任务，陷入了史无前例的危险境地。而失忆的近藤也以为自己是樱井，开始朝着演员之路努力奋斗。正在婚活中的女主编香苗（广末凉子）看到努力的近藤心生爱意，竟然主动向他求婚。失忆、大笔资金、求婚……这些复杂的意外纠结到一起，究竟会酝酿出一部怎样的喜剧？"),
                Movie(name:"投靠女和出走男",id:"2132",info:[ "观看次数":"30",
                    "制片国家/地区":"日本",
                    "主演":"大泉洋  户田惠梨香  满岛光  山崎努  堤真一  树木希林  内山理名",
                    "语言":"日语",
                    "上映日期":"2015-05-16",
                    "片长":"144分钟",
                    "导演":"原田真人",
                    "类型":"剧情",],content:"故事发生在19世纪中叶的日本德川幕府时期，位于镰仓的东庆寺得到幕府的支持，可以向饱受苦难婚姻折磨的女性施以援手，帮助他们成功和夫家断绝关系。这一日，不法商人堀切屋三郎卫门（堤真一饰）的小妾阿吟（满岛光饰）以及被混蛋丈夫（武田真治饰）残酷剥削的铁匠阿茹（户田惠梨香饰）结伴来到东庆寺，并且认识了寺脚下御用宿柏屋主人源兵卫（树木希林饰）的外甥信次郎（大泉洋饰）。信次郎是一名见习医生，他利用艺术尝试着治疗阿茹的烧伤，同时希望记录下女性们的遭遇写出传世剧本。有着不同背景的女性们相继前来，她们共同站在了人生的岔路口上……"),
                Movie(name:"单身指南",id:"2131",info:["观看次数":"189",
                    "制片国家/地区":"美国",
                    "主演":"达科塔·约翰逊  蕾蓓尔·威尔森  爱丽森·布里  莱斯利·曼恩  小达蒙·韦恩斯",
                    "语言":"英语",
                    "上映日期":"2016-02-12",
                    "片长":"109分钟",
                    "导演":"克利斯汀·迪特",
                    "类型":"喜剧", ],content:"这部新片由《爱你，罗茜》克利斯汀·迪特执导，女作家LizTuccillo（《他其实没那么喜欢你》）作品改编，讲述了在纽约生活的一组人互不相干但又相互交织的情感经历。"),
                Movie(name:"老手",id:"2130",info:["观看次数":"154",
                    "制片国家/地区":"韩国",
                    "主演":"黄政民  刘亚仁  柳海真  吴达洙  郑万植  郑雄仁",
                    "语言":"韩语",
                    "上映日期":"2015-08-05",
                    "片长":"124分钟",
                    "导演":"柳昇完",
                    "类型":"剧情", ],content:"广域搜查队的老手精英们各自都有擅长的领域，不过在新的一宗犯罪案中就让他们陷入困境，行动派调查组组长徐道哲（黄政民饰）直觉上认为幕后黑手正是财阀三世赵泰晤（刘亚仁饰），作为行动派刑警代表的徐道哲决定带领一支资深犯罪调查组与目中无人唯我独尊的赵泰晤正面交锋，双方展开了一场智勇博弈。"),
                Movie(name:"愤怒的小鸟",id:"2129",info:["观看次数":"837",
                    "制片国家/地区":"美国",
                    "主演":"杰森·苏戴奇斯  乔什·盖德  丹尼·麦克布耐德  玛娅·鲁道夫",
                    "语言":"国语配音",
                    "上映日期":"2016-05-20",
                    "片长":"97分钟",
                    "导演":"费格尔·雷利  克雷·卡提斯",
                    "类型":"动画", ],content:"《愤怒的小鸟》是由索尼影业出品的动画电影，由费格尔·雷利、克雷·卡提斯执导，乔恩·维迪编剧，杰森·苏戴奇斯、乔什·盖德、丹尼·麦克布耐德等参与配音。该片改编自同名手游，讲述了一群不会飞的小鸟挤在一座热带小岛上，生活和睦宁静，但当神秘的绿色小猪登陆岛屿时，小鸟们平静的生活被打破的故事。"),
                Movie(name:"嫌疑人X的献身",id:"2128",info:["版本":"韩版",
                    "观看次数":"283",
                    "制片国家/地区":"韩国",
                    "主演":"李瑶媛  柳承范  赵镇雄",
                    "语言":"韩语",
                    "上映日期":"2012-10-18",
                    "片长":"118分钟",
                    "导演":"方恩珍",
                    "类型":"悬疑", ],content:"天才数学家石固在一个高中任教，一直过着平凡的生活，突然有一天，他被刚搬到隔壁的女人深深吸引。这个名叫花善的芳邻其实有着非常暗晦的一面。石固偶然间得知，她曾亲手结束了前夫的性命。然而，为了妥善照顾这个女子，石固为其制造了完美的不在场证据，虽然她仍被作为最大嫌疑者而受到警方追查。当测谎仪也无法揭穿这个女子时，警方似乎也渐渐对她放松了警惕。但是具有动物般敏感嗅觉的警探珉范却始终认定花善和此案脱不了干系，并且愈发加大了侦查力度。究竟石固是如何为心上人制造不在场证明的？花善能否侥幸逃过一劫？杀父的背后到底有什么隐情？"),
                Movie(name:"十亿韩元",id:"2127",info:[ "观看次数":"197",
                    "制片国家/地区":"韩国",
                    "主演":"朴海日  申敏儿  朴熙顺  郑有美  高恩雅  李民基  李天熙",
                    "语言":"韩语",
                    "上映日期":"2009-08-06",
                    "片长":"114分钟",
                    "导演":"赵民镐",
                    "类型":"惊悚",],content:"电视制片人韩基泰（朴海日饰）与送外卖的赵有真（申敏儿饰）同其他六位职业、年龄各不相同的陌生男女先后收到奖金高达10亿韩元的网络生存游戏参赛邀请。四队青年男女被节目组送达人迹罕至的澳洲帕斯地区，他们将按照节目导演张明哲（朴熙顺饰）的游戏规则角逐出惟一赢家。但游戏开始之后，参与者们很快感到事情蹊跷，不久即有选手殒命，游戏演变成参与者千方百计摆脱导演控制的亡命旅程，但在这荒无人烟的西澳洲荒漠，导演似乎化身为掌握一切的力量。究竟八人为何被聚在一起？导演意图何在？被解救后的赵有真在病床上回忆起事件的整个经过……"),
                Movie(name:"如此美好",id:"2126",info:["观看次数":"60",
                    "制片国家/地区":"韩国",
                    "主演":"金允石  郑宇  韩孝珠  金喜爱  张铉诚  晋久  姜河那  赵福来",
                    "语言":"韩语",
                    "上映日期":"2015-11-27",
                    "片长":"122分钟",
                    "导演":"金炫锡",
                    "类型":"爱情", ],content:"影片围绕位于首尔武桥洞的音乐工作室C’estsibon展开。该音乐坊曾人才辈出，走出了赵英男、宋昌植、尹亨柱、李章熙等重量级音乐人，并掀起了乡村音乐的热潮，备受乐迷追捧。影片除了以怀旧手法追忆了20年前的音乐往事，也刻画了虚构男主人公根泰的初恋故事，以及多年后与初恋情人重逢的离愁别绪…"),
                Movie(name:"红色警戒999",id:"2125",info:["观看次数":"283",
                    "制片国家/地区":"美国",
                    "主演":"卡西·阿弗莱克　切瓦特·埃加福特　安东尼·麦凯　　亚伦·保尔　小克利夫顿·克林斯",
                    "语言":"",
                    "上映日期":"2016-02-26",
                    "片长":"116分钟",
                    "导演":"约翰·希尔寇特",
                    "类型":"动作", ],content:"影片由《无法无天》导演约翰·希尔寇特执导，讲述劫匪与腐败警察联手，通过杀害一名警官，为劫案声东击西的故事。卡司包括凯特·温斯莱特、卡西·阿弗莱克、切瓦特·埃加福特、亚伦·保罗、伍迪·哈里森等。999是警方无线电通话代码，意思是“警官受伤”。"),
                Movie(name:"哪一天我们会飞",id:"2124",info:["观看次数":"123",
                    "制片国家/地区":"中国香港",
                    "主演":"杨千嬅　林海峰　　钟丽淇　苏丽珊　游学修　吴肇轩　赵学而",
                    "语言":"　粤语/国语",
                    "上映日期":"2016-03-10",
                    "片长":"108分钟",
                    "导演":"黄修平",
                    "类型":"爱情", ],content:"余凤芝和彭盛华结婚十年，生活平淡似水。凤芝在网上偶然发现旧同学──苏博文的博客，唤起凤芝沉睡多时的回忆。英仁书院，1992年，中六转校生余凤芝在歌唱比赛中认识彭盛华和苏博文。盛华外向活泼，梦想成为室内设计师；博文内敛沉郁，擅长制作飞行装置，梦想成为飞机师。他们活在「三人行」的梦幻岁月中，直至开放日之后，苏博文不辞而别，从学校消失了。回到今天，凤芝从一些生活细节中怀疑盛华出轨，此时她心生一问：「为何当时会选择盛华而放弃博文呢？」凤芝重返母校，一幕幕回忆有如电影在脑内放映；凤芝突然醒觉，那个问题的答案，尽在当年那天，那个开放日里;")]
    }
}