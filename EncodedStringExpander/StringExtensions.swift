//
//  StringExtensions.swift
//  EncodedStringExpander
//
//  Created by Steve Baker on 11/3/18.
//  Copyright © 2018 Beepscore LLC. All rights reserved.
//

import Foundation

extension String {

    /// - Returns: true if not empty and contains only decimal digits
    /// https://stackoverflow.com/questions/26545166/how-to-check-is-a-string-or-number#38481180
    func isDigits() -> Bool {
        let isDigits = (!isEmpty)
            && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil

        return isDigits
    }

    /// - Returns: true if doesn't contain any digit or a square bracket "[" or "]"
    func isNotDigitsAndNotSquareBrackets() -> Bool {
        let isNotDigitsAndNotBrackets = (!isEmpty)
            && self.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil
            && !self.contains("[")
            && !self.contains("]")
        return isNotDigitsAndNotBrackets
    }

}
