//
//  StringExtensionsTests.swift
//  EncodedStringExpanderTests
//
//  Created by Steve Baker on 11/3/18.
//  Copyright © 2018 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import EncodedStringExpander

class StringExtensionsTests: XCTestCase {

    func testIsDigits() {
        XCTAssertTrue("123".isDigits())

        XCTAssertFalse("abc".isDigits())
        XCTAssertFalse("[".isDigits())
        XCTAssertFalse("123a".isDigits())
    }

    func testIsNotDigitsAndNotSquareBrackets() {
        XCTAssertTrue("abc".isNotDigitsAndNotSquareBrackets())

        XCTAssertFalse("1[".isNotDigitsAndNotSquareBrackets())
        XCTAssertFalse("[a".isNotDigitsAndNotSquareBrackets())
        XCTAssertFalse("123".isNotDigitsAndNotSquareBrackets())
        XCTAssertFalse("[".isNotDigitsAndNotSquareBrackets())
        XCTAssertFalse("]".isNotDigitsAndNotSquareBrackets())
    }

}
