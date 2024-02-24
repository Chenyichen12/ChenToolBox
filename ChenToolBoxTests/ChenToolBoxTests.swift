//
//  ChenToolBoxTests.swift
//  ChenToolBoxTests
//
//  Created by 陈依澄 on 2023/9/26.
//
import EventKit
import XCTest
@testable import ChenToolBox

final class ChenToolBoxTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
                event.title = "My Event"
                event.startDate = Date()
                event.endDate = Date().addingTimeInterval(3600) // 1 hour
                event.notes = "This is my event"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                // Save the event
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event saved to calendar")
                } catch let error as NSError {
                    print("Error saving event: \(error.localizedDescription)")
                }
            
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
