//
//  StaticData.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/26.
//

import Foundation
import EventKit
struct AppStatic{
    static let eventStore = EKEventStore() // 日历必须的事件商店
    static let appName = "ToolBox By Chenyichen"
    static let calendarName = "Create by chenyichen"
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
    
    static let NumToChinese: [String] =
    ["零","一","二","三","四","五","六","七","八","九"]
    static let NumToDay: [String] =
    ["零","一","二","三","四","五","六","天"]
}
