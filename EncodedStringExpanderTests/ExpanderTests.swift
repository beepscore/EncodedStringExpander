//
//  ExpanderTests.swift
//  EncodedStringExpanderTests
//
//  Created by Steve Baker on 11/2/18.
//  Copyright © 2018 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import EncodedStringExpander

class ExpanderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecoded() {
        XCTAssertEqual(Expander.decoded("[ef]"), "ef")
        XCTAssertEqual(Expander.decoded("2[a]"), "aa")
        XCTAssertEqual(Expander.decoded("3[ab]"), "ababab")
        XCTAssertEqual(Expander.decoded("2[a][bc]"), "aabc")
        XCTAssertEqual(Expander.decoded("3[ab]4[c]"), "abababcccc")
    }

    func testSequentialExpressions() {
        XCTAssertEqual(Expander.sequentialExpressions("2[ab]"), ["2[ab]"])
        XCTAssertEqual(Expander.sequentialExpressions("[a]2[bc]"), ["[a]", "2[bc]"])
        XCTAssertEqual(Expander.sequentialExpressions("2[a][bc]"), ["2[a]", "[bc]"])
    }

    func testMultiplierNil() {
        XCTAssertNil(Expander.multiplier(""))
        XCTAssertNil(Expander.multiplier("[a]"))
    }

    func testMultiplier() {
        XCTAssertEqual(Expander.multiplier("2[a]"), 2)
        XCTAssertEqual(Expander.multiplier("3[ab]"), 3)
        XCTAssertEqual(Expander.multiplier("3[ab]4[c]"), 3)
    }

    func testMultiplierEncodedMalformed() {
        XCTAssertNil(Expander.multiplier("[5]"))
    }

    func testInnerString() {
        XCTAssertEqual(Expander.innerString("2[a]"), "a")
        XCTAssertEqual(Expander.innerString("3[ab]"), "ab")
        XCTAssertEqual(Expander.innerString("3[[ab]4[c]]"), "[ab]4[c]")
    }

}
