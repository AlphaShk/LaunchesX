//
//  LaunchesXTests.swift
//  LaunchesXTests
//
//  Created by Denys Shkola on 17.07.2022.
//

import XCTest
@testable import LaunchesX

class LaunchesXTestExtensions: XCTestCase {
    
    var sut: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = "2000-01-10T10:50:00-04:00"
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFromStringToDateToStringWithQuarterPrecision() throws {
        
        let precision = "quarter"
        
        let date = sut.getDate()
        
        let result = date?.toString(with: precision)
        
        XCTAssertEqual(result, "Winter, 2000")
    }
    
    func testFromStringToDateToStringWithHalfPrecision() throws {
        
        let precision = "half"
        
        let date = sut.getDate()
        
        let result = date?.toString(with: precision)
        
        XCTAssertEqual(result, "1HY, 2000")
    }
    
    func testFromStringToDateToStringWithMonthPrecision() throws {
        
        let precision = "month"
        
        let date = sut.getDate()
        
        let result = date?.toString(with: precision)
        
        XCTAssertEqual(result, "Jan, 2000")
    }
    
    func testFromStringToDateToStringWithDayPrecision() throws {
        
        let precision = "day"
        
        let date = sut.getDate()
        
        let result = date?.toString(with: precision)
        
        XCTAssertEqual(result, "Jan 10, 2000")
    }
    
    func testFromStringToDateToStringWithHourPrecision() throws {
        
        let precision = "hour"
        
        let date = sut.getDate()
        
        let result = date?.toString(with: precision)
        
        XCTAssertEqual(result, "15:50, Jan 10, 2000")
    }
}

class LaunchesXTestManager: XCTestCase {
    
    var sut: LaunchManager!
    let launches = [Launch(links: Links(patch: Patch(small: nil, large: nil), flickr: Flickr(original: []), youtube_id: nil), name: "AB", details: nil, date_local: "2000-01-09T10:50:00-04:00", date_precision: nil), Launch(links: Links(patch: Patch(small: nil, large: nil), flickr: Flickr(original: []), youtube_id: nil), name: "AC", details: nil, date_local: "2000-01-10T10:50:00-04:00", date_precision: nil)]
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = LaunchManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testPerformRequest() {
        sut.performRequest { launches in
            XCTAssertNotNil(launches, "Received data is nil")
            XCTAssert(launches.isEmpty, "Data array is empty")
        }
    }
    func testLaunchesSortingAscending() {
        
        let sortOption: SortOption = .ascending
        
        let result = sut.sortLaunches(launches, by: sortOption)
        
        XCTAssert(result.first?.name == "AB")
    }
    
    func testLaunchesSortingDescending() {
        
        let sortOption: SortOption = .descending
        
        let result = sut.sortLaunches(launches, by: sortOption)
        
        XCTAssert(result.first?.name == "AC")
    }
    
    func testLaunchesSortingDateAscending() {
        
        let sortOption: SortOption = .dateAscending
        
        let result = sut.sortLaunches(launches, by: sortOption)
        
        XCTAssert(result.first?.name == "AB")
    }
    
    func testLaunchesSortingDateDescending() {
        
        let sortOption: SortOption = .dateDescending
        
        let result = sut.sortLaunches(launches, by: sortOption)
        
        XCTAssert(result.first?.name == "AC")
    }
    func testFilter() {
        
        let filter = "c"
        
        let result = sut.filterLaunches(filter: filter, launches: launches)
        
        XCTAssert(result.first?.name == "AC")
    }
}
