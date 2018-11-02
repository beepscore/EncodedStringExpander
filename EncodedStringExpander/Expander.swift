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
    static func decoded(_ encoded: String) -> String {
        return "foo"
    }

}
