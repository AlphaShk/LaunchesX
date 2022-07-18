//
//  LaunchesXUITests.swift
//  LaunchesXUITests
//
//  Created by Denys Shkola on 18.07.2022.
//

import XCTest
@testable import LaunchesX

class LaunchesXUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {}
    
    func testTapTableViewCell() throws {
        
        let table = app.tables.matching(identifier: "tableView")
        if table.cells.count != 0 {
            let cell = table.cells.element(matching: .cell, identifier: "launchesCell")
            XCTAssert(cell.exists)
            cell.tap()
        }
    }
    
}
