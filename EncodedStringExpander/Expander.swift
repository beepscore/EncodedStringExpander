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
    // TODO: Consider shorten method by extracting code or using methods
    // similar to multiplier and innerString
    static func decodedSplits(_ splits: [String]?) -> [String] {

        // base cases
        guard let splits = splits else { return [] }

        if isSplitsFullyExpanded(splits) { return splits }

        // "]" is always the end of an expression
        guard let expressionEndIndex = splits.firstIndex(of: "]") else {
            return splits
        }

        let splitsThroughExpressionEnd = splits[...expressionEndIndex]

        guard let lastLeftBracketIndex = splitsThroughExpressionEnd.lastIndex(of: "[") else {
            // lastLeftBracketIndex was nil, so encoded is malformed
            return splits
        }

        var currentMultiplier = 1
        var expressionStartIndex = lastLeftBracketIndex
        let multiplierLeftLettersRightCount = 4
        if splitsThroughExpressionEnd.count >= multiplierLeftLettersRightCount
            && splitsThroughExpressionEnd[lastLeftBracketIndex - 1].isDigits() {
            expressionStartIndex = lastLeftBracketIndex - 1
            currentMultiplier = Int(splitsThroughExpressionEnd[expressionStartIndex]) ?? 1
        }

        // expressionSplits slice uses original indexes
        var expressionSplits = splitsThroughExpressionEnd[expressionStartIndex...expressionEndIndex]

        var letters = ""
        let lettersRightCount = 2
        if expressionSplits.count >= lettersRightCount {
            let lettersIndex = expressionSplits.index(before: expressionEndIndex)
            if expressionSplits[lettersIndex].isNotDigitsAndNotSquareBrackets() {
                letters = expressionSplits[lettersIndex]
            }
        }

        let expressionExpanded = String(repeating: letters, count: currentMultiplier)

        // substitute in encoded
        var newSplits = Array(splits[..<expressionStartIndex])
        newSplits.append(expressionExpanded)

        var newSplitsTail = [String]()
        //if expressionSplits.endIndex < splits.endIndex - 1 {
        if expressionSplits.endIndex < splits.endIndex {
            // expression ends before end of splits
            let newSplitsTailStartIndex = splits.index(after: expressionEndIndex)
            newSplitsTail = Array(splits[newSplitsTailStartIndex..<splits.endIndex])
        }

        newSplits += newSplitsTail

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

    // TODO: Consider delete unused method.
    static func multiplier(_ encoded: String) -> Int? {
        guard let firstLeftBracketIndex = encoded.firstIndex(of: "[") else { return nil }

        let prefix = String(encoded[..<firstLeftBracketIndex])

        // remove non digit characters
        // alternatively could use .filter and scalar view, might not be as robust
        // https://stackoverflow.com/questions/36594179/remove-all-non-numeric-characters-from-a-string-in-swift#36607684
        let digitsArray = prefix.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let digitsString = digitsArray.joined()
        return Int(digitsString)
    }

    // TODO: Consider delete unused method.
    static func innerString(_ encoded: String) -> String? {

        guard let firstLeftBracketIndex = encoded.firstIndex(of: "[") else {
            // assume string isn't malformed, doesn't have a right bracket "]" either
            return encoded
        }

        let innerStart = encoded.index(after: firstLeftBracketIndex)

        guard let lastRightBracketIndex = encoded.lastIndex(of: "]") else {
            // firstLeftBracketIndex was nil, so encoded is malformed
            return nil
        }

        guard encoded.count >= 2 else {
            // string is too short to get index before lastRightBracketIndex
            return nil
        }

        let innerEnd = encoded.index(before: lastRightBracketIndex)

        // don't remove digits, they may be needed for nested substrings
        let innerString = String(encoded[innerStart...innerEnd])

        return innerString
    }

}
