//
//  Expander.swift
//  EncodedStringExpander
//
//  Created by Steve Baker on 11/2/18.
//  Copyright © 2018 Beepscore LLC. All rights reserved.
//

import Foundation

struct Expander {

    /// Expands an encoded string of one or more sequential and/or nested expressions.
    ///
    /// Examples:
    ///
    /// encoded string -> decoded string
    ///
    ///  "2[ab]" -> "abab"
    ///
    /// "3[[a]2[bc]]" -> "abcbcabcbcabcbc"
    ///
    ///  If multiplier prefix is absent use 1 as the implicit default.
    ///
    ///  "[ef]" -> "ef"
    ///
    ///  The multiplier distributes only over immediatedly following substring
    ///
    ///  "2[a][bc]" -> "aabc"
    ///
    /// Assumes the encoded string is not malformed.
    ///
    /// - Parameter encoded: the encoded string
    ///   May contain a multiplier prefix before a bracket [] delimited inner string
    ///   The multiplier contains decimal digits.
    ///   The substring to be expanded does not contain decimal digits.
    ///   The string may be nested.
    /// - Returns: expanded string
    static func decoded(_ encoded: String?) -> String {

        // base cases
        guard let encoded = encoded else { return "" }
        if encoded.isEmpty { return "" }

        let splits = Expander.splitAtBrackets(encoded)

        if splits.isEmpty { return "" }

        let expanded = decodedSplits(splits)
        return expanded.joined()
    }

    //////////////////////////////////////////////////
    /// methods below are public for use by unit tests

    /// - Parameter encoded: encoded string
    /// - Returns: an array from splitting encoded at each bracket "[" or "]"
    static func splitAtBrackets(_ encoded: String?) -> [String] {

        // base cases
        guard let encoded = encoded else { return [] }
        if encoded.isEmpty { return [] }

        // insert a separator
        let separator = ","
        var encodedWithSeparator = encoded
            .replacingOccurrences(of: "]", with: "\(separator)]\(separator)")
        encodedWithSeparator = encodedWithSeparator
            .replacingOccurrences(of: "[", with: "\(separator)[\(separator)")

        var components =  encodedWithSeparator.components(separatedBy: separator)

        // remove any empty strings
        components = components.filter {!$0.isEmpty}
        return components
    }
    
    // TODO: Consider change to a method that acts more like a hand held calculator stack.
    static func decodedSplits(_ splits: [String]?) -> [String] {

        // base cases
        guard let splits = splits else { return [] }

        if isSplitsFullyExpanded(splits) { return splits }

        // "]" is always the end of an expression
        guard let expressionEndIndex = splits.firstIndex(of: "]") else { return splits }

        let splitsThroughExpressionEnd = splits[...expressionEndIndex]

        guard let lastLeftBracketIndex = splitsThroughExpressionEnd.lastIndex(of: "[") else {
            // lastLeftBracketIndex was nil, so encoded is malformed
            return splits
        }

        let startIndex = expressionStartIndex(splitsThroughExpressionEnd: Array(splitsThroughExpressionEnd), lastLeftBracketIndex: lastLeftBracketIndex)

        // expressionSplits slice uses original indexes from splitsThroughExpressionEnd
        let expressionSplits = splitsThroughExpressionEnd[startIndex...expressionEndIndex]
        // create a new Array to get index starting at 0
        let expression = Array(expressionSplits)

        let currentMultiplier = multiplier(expression: expression)
        let expressionLetters = letters(expression: expression) ?? ""
        let expressionExpanded = String(repeating: expressionLetters,
                                        count: currentMultiplier)

        let newSplits = splitsByExpandingExpression(splits: splits,
                                                    expressionStartIndex: startIndex,
                                                    expressionEndIndex: expressionEndIndex,
                                                    expressionExpanded: expressionExpanded)

        let splitsCondensed = condensedSplits(newSplits)

        return decodedSplits(splitsCondensed)
    }

    /// - Parameter splits: array originally from splitting encoded at each bracket "[" or "]"
    ///   splits may have been processed to alter elements
    /// - Returns: true if every element is "letters", i.e. not digits and not a square bracket
    static func isSplitsFullyExpanded(_ splits: [String]) -> Bool {

        var isFullyExpanded = true
        for element in splits {
            if !element.isNotDigitsAndNotSquareBrackets() {
                isFullyExpanded = false
                break
            }
        }
        return isFullyExpanded
    }

    // TODO: Consider may be able to increase efficiency by only processing last 2 elements
    /// - Parameter splits: array originally from splitting encoded at each bracket "[" or "]"
    ///   splits may have been processed to alter elements
    /// - Returns: array by joining any adjacent elements that are alpha
    static func condensedSplits(_ splits: [String]) -> [String] {
        // make a pass to join any adjacent letter elements
        var splitsCondensed = splits
        // loop from end to beginning so removing from right won't disrupt lower indices
        for index in (0..<splits.count).reversed() {
            if index > 0
                && splits[index].isNotDigitsAndNotSquareBrackets()
                && splits[index - 1].isNotDigitsAndNotSquareBrackets() {
                splitsCondensed[index - 1] = splits[index - 1] + splits[index]
                splitsCondensed.remove(at: index)
            }
        }
        return splitsCondensed
    }

    /// - Parameters:
    ///   - splitsThroughExpressionEnd:
    ///   - lastLeftBracketIndex: index of last left bracket "[" in splitsThroughExpressionEnd
    /// - Returns: start index.
    ///   If element before x is digits, returns index of digits.
    ///   else returns lastLeftBracketIndex
    static func expressionStartIndex(splitsThroughExpressionEnd: [String],
                                     lastLeftBracketIndex: Int) -> Int {

        var expressionStartIndex = lastLeftBracketIndex

        // number of elements in multiplier, "[", letters, "]"
        let multiplierLeftLettersRightCount = 4

        if splitsThroughExpressionEnd.count >= multiplierLeftLettersRightCount
            && splitsThroughExpressionEnd[lastLeftBracketIndex - 1].isDigits() {
            expressionStartIndex = lastLeftBracketIndex - 1
        }
        return expressionStartIndex
    }

    /// - Parameter expression: an array with starting index 0, not a slice of another array
    ///   a valid expression should have count 0 or 3 or 4.
    /// - Returns: multiplier Int(digits) if expression starts with digits, else 1.
    static func multiplier(expression: [String]) -> Int {

        guard let expressionFirst = expression.first else { return 1 }

        // number of elements in multiplier, "[", letters, "]"
        let multiplierLeftLettersRightCount = 4

        var currentMultiplier = 1

        if expression.count >= multiplierLeftLettersRightCount
            && expressionFirst.isDigits() {
            // expect multiplier at expressionFirst
            currentMultiplier = Int(expressionFirst) ?? 1
        }
        return currentMultiplier
    }

    static func letters(expression: [String]) -> String? {
        var letters = ""

        if expression.count == 0 { return nil }

        if expression.count == 1 {
            let expressionFirst = expression.first ?? ""
            
            if expressionFirst.isEmpty { return "" }

            if expressionFirst.isNotDigitsAndNotSquareBrackets() {
                return expressionFirst
            } else {
                return nil
            }
        }

        // number of elements in letters, "]"
        let lettersRightCount = 2
        // conditional check is important to avoid potential error in index(before) below.
        // this conditional is redundant as long as preceeding code checks for 0 and 1.
        guard expression.count >= lettersRightCount else {
            return nil
        }

        // "]" is always the end of an expression
        guard let expressionEndIndex = expression.firstIndex(of: "]") else {
            return nil
        }

        let lettersIndex = expression.index(before: expressionEndIndex)

        if expression[lettersIndex].isNotDigitsAndNotSquareBrackets() {
            letters = expression[lettersIndex]
        }

        return letters
    }

    /// - Parameter splits: array originally from splitting encoded at each bracket "[" or "]"
    ///   splits may have been processed to alter elements
    /// - Returns: array by replacing elements from expressionStartIndex to expressionEndIndex with one element expressionExpanded
    static func splitsByExpandingExpression(splits: [String],
                                            expressionStartIndex: Int,
                                            expressionEndIndex: Int,
                                            expressionExpanded: String) -> [String] {

        // substitute in encoded
        var newSplits = Array(splits[..<expressionStartIndex])
        newSplits.append(expressionExpanded)

        var newSplitsTail = [String]()
        //if expressionSplits.endIndex < splits.endIndex - 1 {
        if expressionEndIndex < splits.endIndex {
            // expression ends before end of splits
            let newSplitsTailStartIndex = splits.index(after: expressionEndIndex)
            newSplitsTail = Array(splits[newSplitsTailStartIndex..<splits.endIndex])
        }

        newSplits += newSplitsTail
        return newSplits
    }

}
