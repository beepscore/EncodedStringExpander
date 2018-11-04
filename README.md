# Purpose
Expand an encoded string.

# Results

# Background
As a challenge, write app without referencing any sources related to string decoding problem except for Appendix- notes.

For example don't research solutions that act like a hand held calculator stack.

I think Stanford iOS lectures by Paul Haggerty(sp?) showed a calculator program.

Also LISP and FORTH programs do this.

May reference outside sources for other topics such as string methods.

## Alternative solutions

### split encoded string into array
Search array for first expression and expand it.
Recurse.
This is similar to a calculator stack but probably less efficient.

### calculator stack
Process encoded string sequentially.
Whenever get an expression-ending "]", expand the expression.

### json
Transform encoded expression into valid JSON.
Then use Encodable protocol to parse json into structs or objects.
Then simplify.
This is interesting but probably unneccessarily complicated.

## other results
See code and tests.

# References
## Appendix- notes

# Appendix- notes

Write a method that takes an encoded string, fully expands it and returns the decoded string.

decode(encodedString: String) -> String

The string may contain a multiplier prefix before a bracket [] delimited inner string.
The string may be nested.

Examples:
encoded string -> decoded string
"2[ab]" -> "abab"
"3[[a]2[bc]]" -> "abcbcabcbcabcbc"

Assume the encoded string is not malformed.
Assume the multiplier contains decimal digits.
Assume the substring to be expanded does not contain decimal digits.

My additional assumptions
Assume if multiplier prefix is absent use 1 as the implicit default.
"[ef]" "ef"
Assume multiplier distributes only over immediatedly following substring
"2[a][b]" "aab"
