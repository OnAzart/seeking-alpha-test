# Write an application in any of the following languages (Scala/Python/Java) that adds a
# specific character before every occurrence of a character sequence in a string.
# What is the complexity of your solution?
# Example:
# Given the following string “abcalphacdealphaxalph” and the character ”_” and
# string ”alpha” the output should be ”abc_alphacde_alphaxalph”

# Usage example: python 4.py abcalphacdealphaxalph _ alpha

import sys

string = sys.argv[1]
character = sys.argv[2]
substring = sys.argv[3]

output = string.replace(substring, character+substring)
print(output)

# WHAT is the complexity?
# Time - O(n)
# Memory - O(n)
