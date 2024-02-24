//
//  AddDataToCalendar.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/26.
//

import Foundation
import EventKit

// 默认weeks day是不为nil的
func saveLessonsToCalendar(lessons: [Lesson], startDate: Date) throws{
    
    //test
    let createCalendar = findCalendar()
    try AppStatic.eventStore.saveCalendar(createCalendar, commit: true)
    let startDateComp = Calendar.current.dateComponents(in: TimeZone.current, from: startDate)
    let startWeek = startDateComp.weekOfYear
    let startYear = startDateComp.year
    for lesson in lessons{
        let title = lesson.Name
        let location = lesson.Location ?? "未排地点"
        let Day = lesson.Day!
        let staTime = AppStatic.TimeTableUniversity[lesson.startAndEnd.0][0]
        let endTime = AppStatic.TimeTableUniversity[lesson.startAndEnd.1][1]
        
        for itweek in lesson.Weeks!{
            let event = EKEvent(eventStore: AppStatic.eventStore)
            var thisDateComp = DateComponents()
            thisDateComp.year = startYear
            thisDateComp.weekOfYear = itweek + startWeek! - 1
            thisDateComp.weekday = Day+1 //由于外国人认为周天是第一天
            thisDateComp.hour = staTime.0
            thisDateComp.minute = staTime.1
            
            let staDate = Calendar.current.date(from: thisDateComp)
            
            thisDateComp.hour = endTime.0
            thisDateComp.minute = endTime.1
            let endDate = Calendar.current.date(from: thisDateComp)
            event.title = title
            event.location = location
            event.startDate = staDate
            event.endDate = endDate
            //event.notes = "??" 增加备注
            event.calendar = createCalendar
            
            
            //添加
            try AppStatic.eventStore.save(event, span: .thisEvent)
            print("saved")
        }
    }
}

func findCalendar() -> EKCalendar{
    let allCalendar = AppStatic.eventStore.calendars(for: .event)
    for calendar in allCalendar {
        if(calendar.title == AppStatic.calendarName){ return calendar }
    }
    let calendar = EKCalendar(for: .event, eventStore: AppStatic.eventStore)
    calendar.title = AppStatic.calendarName
    calendar.source = AppStatic.eventStore.defaultCalendarForNewEvents?.source // 通过默认日历创建日历
    return calendar
}
