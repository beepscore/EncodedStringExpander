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

    func testDecoded() {
        XCTAssertEqual(Expander.decoded("[ef]"), "ef")
        XCTAssertEqual(Expander.decoded("2[a]"), "aa")
        XCTAssertEqual(Expander.decoded("3[ab]"), "ababab")
        XCTAssertEqual(Expander.decoded("2[a][bc]"), "aabc")
    }

    func testDecodedSeqentialMultipliers() {
        XCTAssertEqual(Expander.decoded("3[ab]4[c]"), "abababcccc")
    }

    func testDecodedNested() {
        XCTAssertEqual(Expander.decoded("3[[c]2[d]]"), "cddcddcdd")

        XCTAssertEqual(Expander.decoded("2[1[ab]3[[c]4[d]]]"), "abcddddcddddcddddabcddddcddddcdddd")
    }

    func testSplitAtBrackets() {
        XCTAssertEqual(Expander.splitAtBrackets("3[[c]2[d]]"),
                       ["3", "[", "[", "c", "]", "2", "[", "d", "]", "]"])

        XCTAssertEqual(Expander.splitAtBrackets("[ab]3[[c]4[d]]"),
                       ["[", "ab", "]", "3", "[", "[", "c", "]", "4", "[", "d", "]", "]"])
    }

    func testDecodedSplits() {
        var splits = ["3", "[", "[", "c", "]", "2", "[", "d", "]", "]"]
        XCTAssertEqual(Expander.decodedSplits(splits),
                       ["cddcddcdd"])

        splits = Expander.splitAtBrackets("2[1[ab]3[[c]4[d]]]")
        XCTAssertEqual(Expander.decodedSplits(splits),
                       ["abcddddcddddcddddabcddddcddddcdddd"])
    }

    func testIsSplitsFullyExpandedTrue() {
        var splits = [String]()
        XCTAssertTrue(Expander.isSplitsFullyExpanded(splits))

        XCTAssertTrue(Expander.isSplitsFullyExpanded(["a"]))

        splits = ["abc", "def"]
        XCTAssertTrue(Expander.isSplitsFullyExpanded(splits))
    }

    func testIsSplitsFullyExpandedFalse() {
        XCTAssertFalse(Expander.isSplitsFullyExpanded(["["]))
        XCTAssertFalse(Expander.isSplitsFullyExpanded(["]"]))
        XCTAssertFalse(Expander.isSplitsFullyExpanded(["3"]))

        let splits = ["ab", "3", "[", "c", "dddd", "]"]
        XCTAssertFalse(Expander.isSplitsFullyExpanded(splits))
    }

    func testCondensedSplits() {
        var splits = [String]()
        XCTAssertEqual(Expander.condensedSplits(splits), [])

        splits = ["abc", "def"]
        XCTAssertEqual(Expander.condensedSplits(splits), ["abcdef"])

        splits = ["ab", "3", "[", "c", "dddd", "]"]
        XCTAssertEqual(Expander.condensedSplits(splits),
                       ["ab", "3", "[", "cdddd", "]"])
    }

    func testMultiplierExpression() {
        XCTAssertEqual(Expander.multiplier(expression: [""]), 1)
        XCTAssertEqual(Expander.multiplier(expression: ["2", "[", "a", "]"]), 2)
        XCTAssertEqual(Expander.multiplier(expression: ["3", "[", "ab", "]"]), 3)
        XCTAssertEqual(Expander.multiplier(expression: ["3", "[", "ab", "]", "4", "[", "c", "]"]), 3)
    }

    func testMultiplierExpressionMalformed() {
        XCTAssertEqual(Expander.multiplier(expression: ["ab"]), 1)
        XCTAssertEqual(Expander.multiplier(expression: ["[5]"]), 1)
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

}
