//
//  LaunchesXUITestsLaunchTests.swift
//  LaunchesXUITests
//
//  Created by Denys Shkola on 18.07.2022.
//

import XCTest
@testable import LaunchesX

class LaunchesXUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
}
