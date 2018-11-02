# Purpose
Expand an encoded string.

# References
Write app without referencing any sources related to string decoding problem except for Appendix- notes.
May reference outside sources for other topics such as string methods.

## Appendix- notes

# Results
See code

## Appendix- notes

Write a method that takes an encoded string, fully expands it and returns the decoded string.

decode(encodedString: String) -> String

The string may contain a multiplier prefix before a bracket [] delimited inner string.
The string may be nested.

Examples:
encoded string -> decoded string
"2[ab]"  "abab"
"3[[a]2[bc]]" "abcbcabcbcabcbc"

Assume the encoded string is not malformed.
Assume the multiplier contains decimal digits.
Assume the substring to be expanded does not contain decimal digits.

My additional assumptions
Assume if multiplier prefix is absent use 1 as the implicit default.
"[ef]" "ef"
Assume multiplier distributes only over immediatedly following substring
"2[a][b]" "aab"
