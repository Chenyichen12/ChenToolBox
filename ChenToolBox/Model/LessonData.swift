//
//  LessonsData.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/26.
//
import Foundation
import SwiftSoup
import EventKit

struct Lesson: Identifiable{
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        return lhs.id == rhs.id &&
        lhs.Name == rhs.Name &&
        lhs.Day == rhs.Day &&
        lhs.Location == rhs.Location &&
        lhs.startAndEnd == rhs.startAndEnd &&
        lhs.Weeks == rhs.Weeks
    }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    
    let id = UUID()
    var Name: String
    var Day: Int?
    var Location: String?
    var startAndEnd: (Int,Int)
    var Weeks: [Int]?
    
    var isComplete: Bool{
        get{
            if(self.Weeks != nil && self.Day != nil){ return true }
            else{return false}
        }
    }
}
extension Lesson: Equatable{
    
}

//
//  File.swift
//  ScutSchedule
//
//  Created by 陈鹏宇 on 2023/9/12.
//


class GetImformation{
    private init(){} // 方法类
    
    static func parseHTML(_ HTML: String) throws -> [Lesson]{
        do {
            let doc: Document = try SwiftSoup.parse(HTML)
            var AllData = [Lesson]() // All data will be added here
            let element = try doc.getElementById("table2")
            
            if(element != nil){
                //get days message
                for i in 0...6{
                    let temp = getOneDayData(dayELement: element!, dayId: "xq_\(i+1)")
                    if(temp == nil){continue}
                    for t in temp!{AllData.append(t)} //Add data to database
                }
                return AllData
            }
            else {
                throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "没有课表")
            }
        } catch Exception.Error(_,  let message) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: message)
            
        } catch {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "位置错误")
        }
    }
    
    static func getOneDayData(dayELement:Element, dayId: String) -> [Lesson]?{
        let elements = try? dayELement.getElementById(dayId)?.getElementsByTag("td")
        if(elements == nil){return nil}
        var res = [Lesson]()
        var startAndEnd: (Int,Int) = (0,0) // 日了 在哪几节课竟然和名称详细信息不在一个element里
        let today = Int(dayId.suffix(1))
        for element in elements!{
            let startAndEndtemp = getStartAndEnd(timeElement: element)// 返回nil不处理，返回（0，0）和其他正确的就赋值
            if(startAndEndtemp != nil){startAndEnd = startAndEndtemp!}
            let name = getName(nameElement: element)
            if(name == "" || name == nil){continue} // 没有名字说明没有这个元素 不用检查下面的东西力
            let location = getLocation(locationElement: element)//如果为空则没有这个地点
            let rangeWeeks = getWeeks(weekElement: element) // 返回nil数据非法，其余返回正常数据，返回“”说明是没有周数
            if(rangeWeeks == nil){continue} //周数数据非法
            
            let thisLesson = Lesson(Name: name!,Day: today, Location: location,startAndEnd: startAndEnd,Weeks: rangeWeeks)
            res.append(thisLesson) //加入数据链
            
            
//            if(startAndEndtemp == nil){
//                let thisLesson = Lesson(Name: name!, Day: today!, Location: location, StartTime: startAndEnd.0, EndTime: startAndEnd.1, Weeks: rangeWeeks!)
//                res.append(thisLesson) //加入数据链
//                continue
//            }
//            else{
//                startAndEnd = startAndEndtemp!
//                let thisLesson = Lesson(Name: name!, Day: today!, Location: location, StartTime: startAndEnd.0, EndTime: startAndEnd.1, Weeks: rangeWeeks!)
//                res.append(thisLesson) //加入数据链
//            }
        }
        return res
    }
    
    public static func getName(nameElement:Element) -> String?{
        let nameTag = try? nameElement.getElementsByClass("title")
        var nameStr = ""
        if(nameTag == nil){return nil}
        for names in nameTag!{
            let nameAll = try? names.getAllElements()
            if(nameAll == nil){continue}
            for name in nameAll!{
                nameStr += name.ownText()
            }
        }
        return nameStr
    }
    
    public static func getLocation(locationElement: Element) -> String?{
        let p = Pattern.compile("上课地点：") //"([A,B]\\d{4}|未排地点)"
        let locations = try? locationElement.getElementsMatchingOwnText(p)
        if(locations == nil){return nil}
        for loc in locations!{
            if(loc.ownText() != ""){
//                let a = /([A,B]\d{4}|未排地点)/
//                let res = try? a.firstMatch(in: loc.ownText())
//                if(res == nil){return ""}
//                return String(res!.0)
                
//                res = loc.ownText().suffix(4)
//                return String(res)
                let p = /上课地点：/
                let res = try? p.firstMatch(in: loc.ownText())
                if(res == nil){return ""}
                let substr = res!.0.endIndex
                return String(loc.ownText().suffix(from: substr)) == "未排地点" ? nil : String(loc.ownText().suffix(from: substr))
            }
        }
        return nil
    }
    
    public static func getStartAndEnd(timeElement: Element) -> (Int,Int)?{
        let startandend = try? timeElement.getElementsByClass("festival")
        if(startandend == nil){return nil}//没找到返回nil
        else{
            for sd in startandend!{
                if(sd.ownText() == ""){return (0,0)}
                else{
                    //处理时间
                    let staend = sd.ownText().split(separator: "-")
                    let s = Int(staend[0])
                    let e = Int(staend[1])
                    if(s != nil && e != nil){return (s!,e!)}
                    else{return nil}//数据有问题返回nil
                }
            }
        }
        return nil //到底是什么奇妙数据会到这里
    }
    
    public static func getWeeks(weekElement:Element) -> [Int]?{
        //获取原文本
        let weekElements = try? weekElement.getElementsMatchingOwnText(Pattern.compile("周数"))
        if(weekElements == nil){return nil} //没有周数返回空数组
        for weeks in weekElements!{
            if(weeks.ownText() == ""){continue}//没有文本继续
            let weekStr = weeks.ownText()
            var isSp = 0// 0 正常 1单周 2双周
            if(weekStr.contains("(单)")){isSp = 1}
            if(weekStr.contains("(双)")){isSp = 2}
            let substr = weekStr.ranges(of: /(\d+-\d+)|(\d+)/) //"(\\d+-\\d+)|(\\d+)"
            var datas = [Substring]()
            for data in substr{
                datas.append(weekStr[data])
            }
            if(datas.count == 0){return nil} // 看来数据非法
            //要判断是不是单双周
            return parseWeeksText(Data: datas, isSp: isSp)
        }
        //什么逆天数据会到这里
        return nil
    }
    static func parseWeeksText(Data: [Substring],isSp: Int) -> [Int]{
        var res = [Int]()
        for dataStr in Data{
            let i = dataStr.split(separator: "-")//分割后的结果
            if(i.count == 1){//一周的情况
                let dataint = Int(i[0])
                res.append(dataint!) // 添加一周的情况
            }
            else{
                let pre = Int(i[0])
                let suf = Int(i[1])
                //移除单双周数据
                switch isSp{
                case 0:
                    for j in pre!...suf!{res.append(j)} // 添加数据
                case 1:
                    for j in pre!...suf!{
                        if(j%2 == 0){continue}//双周跳过
                        else{res.append(j)}
                    }
                case 2:
                    for j in pre!...suf!{
                        if(j%2 == 0){res.append(j)}//双周添加
                        else{continue}
                    }
                default:
                    return res //怎么才能走到这里
                }
            }
        }
        return res //正常走不到这里hhh
    }
    
    
    
    
//    public static func createLessonList(lessons: [Lesson], startDate: Date, eventstore: EKEventStore,defaultCalendar: EKCalendar) -> [EKEvent]{
//        
//        let startDatecomp = Calendar.current.dateComponents(in: TimeZone.current, from: startDate)  //先转化为datecompoents类型
//        let startWeek = startDatecomp.weekOfYear
//        let startYear = startDatecomp.year //取得第一周的数据
//        var eventBox = [EKEvent]()
//        for lesson in lessons {
//            let title = lesson.Name
//            let location = lesson.Location
//            let Day = lesson.Day
//            let sta = TimeTableUniversity[lesson.StartTime][0]
//            let end = TimeTableUniversity[lesson.EndTime][1]
//            let cla = eventstore.calendar(withIdentifier: "")
//            //每周都要建立一个
//            for itweek in lesson.Weeks{
//                let event = EKEvent(eventStore: eventstore)
//                var thisDateComp = DateComponents()
//                thisDateComp.year = startYear
//                thisDateComp.weekOfYear = itweek + startWeek! - 1
//                thisDateComp.weekday = Day + 1
//                thisDateComp.hour = sta.0
//                thisDateComp.minute = sta.1
//                
//                //创建开始date
//                let staDate = Calendar.current.date(from: thisDateComp)
//                //创建结束date
//                thisDateComp.hour = end.0
//                thisDateComp.minute = end.1
//                let endDate = Calendar.current.date(from: thisDateComp)
//                event.title = title
//                event.location = location
//                event.startDate = staDate
//                event.endDate = endDate
//                event.notes = "Create By Chenyichen"
//                event.calendar = defaultCalendar
//                eventBox.append(event)
//            }
//        }
//        return eventBox
//    }
    
    
    
    
    
    
    static let  TimeTableUniversity: [[(Int,Int)]] =
    [[(0,0),(0,0)], // 0 出错
     [(8,50),(9,35)], // 1
     [(9,40),(10,25)], // 2
     [(10,40),(11,25)],// 3
     [(11,30),(12,15)],// 4
     [(14,0),(14,45)],// 5
     [(14,50),(15,35)],// 6
     [(15,45),(16,30)],// 7
     [(16,35),(17,20)], // 8
     [(19,0),(19,45)], //9
     [(19,55), (20,40)], //10
     [(20,50),(21,35)], // 11
     [(21,40),(22,35)] //12
    ]
    
}
