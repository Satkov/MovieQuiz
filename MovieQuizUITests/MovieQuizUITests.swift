//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Georgy Satkov on 15.06.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super .tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton() {
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()

        let secondPoster = app.images["Poster"]
        sleep(3)
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()

        let secondPoster = app.images["Poster"]
        sleep(3)
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testResultAllert() {
        sleep(2)
        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Result Alert"]

        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testResultAllerDismiss() {
        sleep(2)
        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        sleep(2)
        let alert = app.alerts["Result Alert"]

        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        XCTAssertFalse(alert.exists)
    }
}
