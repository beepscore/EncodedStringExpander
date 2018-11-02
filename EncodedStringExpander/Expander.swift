//
//  Expander.swift
//  EncodedStringExpander
//
//  Created by Steve Baker on 11/2/18.
//  Copyright © 2018 Beepscore LLC. All rights reserved.
//

import Foundation

struct Expander {

    /// Takes an encoded string, fully expands it and returns the decoded string.
    ///
    /// Examples:
    ///
    /// encoded string -> decoded string
    ///
    ///  "2[ab]"  "abab"
    ///
    /// "3[[a]2[bc]]" "abcbcabcbcabcbc"
    ///
    ///  If multiplier prefix is absent use 1 as the implicit default.
    ///
    ///  "[ef]" "ef"
    ///
    ///  The multiplier distributes only over immediatedly following substring
    ///
    ///  "2[a][b]" "aab"
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
        
        guard let inner = Expander.innerString(encoded) else { return "" }

        if inner == "" { return inner }
        if inner == encoded {
            // encoded doesn't have a multiplier
            return inner
        }

        let multiple = Expander.multiplier(encoded) ?? 1

        return String(repeating: decoded(inner), count: multiple)
    }

    /// public for use by unit tests

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
