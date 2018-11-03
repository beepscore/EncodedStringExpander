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
        if encoded == "" { return "" }

        let sequentialExpressions = Expander.sequentialExpressions(encoded)

        var concatenated = ""
        for expression in sequentialExpressions {
            concatenated += Expander.decodedSubstring(expression)
        }

        return concatenated
    }

    //////////////////////////////////////////////////
    /// methods below are public for use by unit tests

    /// Parses an encoded string into sequential expressions
    /// If encoded contains any pattern "a[", "][", "]d", "]^d" then it has sequential expressions
    ///
    /// Examples:
    ///
    /// encoded string -> sequential expressions
    ///
    ///    "2[ab]" ->  ["2[ab]"]
    /// "[a]2[bc]" ->  ["[a]", "2[bc]"]
    /// "2[a][bc]" ->  ["2[a]", "[bc]"]
    /// - Parameter encoded: the encoded string
    /// - Returns:  sequential expressions including multipliers. May return empty array []
    static func sequentialExpressions(_ encoded: String) -> [String] {
        
        // insert a separator
        let separator = ","
        let encodedWithSeparator = encoded.replacingOccurrences(of: "]", with: "]\(separator)")

        var components =  encodedWithSeparator.components(separatedBy: separator)
        if components.last == "" {
            _ = components.popLast()
        }
        return components
    }

    static func decodedSubstring(_ encoded: String?) -> String {

        guard let encoded = encoded else { return "" }
        if encoded == "" { return "" }

        guard let inner = Expander.innerString(encoded) else { return "" }

        if inner == "" { return inner }
        if inner == encoded {
            // encoded doesn't have a multiplier
            return inner
        }

        let multiple = Expander.multiplier(encoded) ?? 1

        return String(repeating: decoded(inner), count: multiple)
    }

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
