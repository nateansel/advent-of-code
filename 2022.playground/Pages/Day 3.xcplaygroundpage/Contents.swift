/*:
 [Previous](@previous)

 # Day 3: Rucksack Reorganization

 ## Part One

 One Elf has the important job of loading all of the [rucksacks](https://en.wikipedia.org/wiki/Rucksack) with supplies for the jungle journey. Unfortunately, that Elf didn't quite follow the packing instructions, and so a few items now need to be rearranged.

 Each rucksack has two large **compartments**. All items of a given type are meant to go into exactly one of the two compartments. The Elf that did the packing failed to follow this rule for exactly one item type per rucksack.

 The Elves have made a list of all of the items currently in each rucksack (your puzzle input), but they need your help finding the errors. Every item type is identified by a single lowercase or uppercase letter (that is, a and A refer to different types of items).

 The list of items for each rucksack is given as characters all on a single line. A given rucksack always has the same number of items in each of its two compartments, so the first half of the characters represent items in the first compartment, while the second half of the characters represent items in the second compartment.

 For example, suppose you have the following list of contents from six rucksacks:

 ```
 vJrwpWtwJgWrhcsFMMfFFhFp
 jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
 PmmdzqPrVvPwwTWBwg
 wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
 ttgJtRGJQctTZtZT
 CrZsJsPPZsGzwwsLwLmpwMDw
 ```

 - The first rucksack contains the items `vJrwpWtwJgWrhcsFMMfFFhFp`, which means its first compartment contains the items `vJrwpWtwJgWr`, while the second compartment contains the items `hcsFMMfFFhFp`. The only item type that appears in both compartments is lowercase **`p`**.
 - The second rucksack's compartments contain `jqHRNqRjqzjGDLGL` and `rsFMfFZSrLrFZsSL`. The only item type that appears in both compartments is uppercase **`L`**.
 - The third rucksack's compartments contain `PmmdzqPrV` and `vPwwTWBwg`; the only common item type is uppercase **`P`**.
 - The fourth rucksack's compartments only share item type **`v`**.
 - The fifth rucksack's compartments only share item type **`t`**.
 - The sixth rucksack's compartments only share item type **`s`**.

 To help prioritize item rearrangement, every item type can be converted to a **priority**:

 - Lowercase item types `a` through `z` have priorities 1 through 26.
 - Uppercase item types `A` through `Z` have priorities 27 through 52.

 In the above example, the priority of the item type that appears in both compartments of each rucksack is 16 (`p`), 38 (`L`), 42 (`P`), 22 (`v`), 20 (`t`), and 19 (`s`); the sum of these is **`157`**.

 Find the item type that appears in both compartments of each rucksack. **What is the sum of the priorities of those item types?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

let priorities: [Character: Int] = [
    "a": 1,  "b": 2,  "c": 3,  "d": 4,  "e": 5,  "f": 6,  "g": 7,  "h": 8,  "i": 9,
    "j": 10, "k": 11, "l": 12, "m": 13, "n": 14, "o": 15, "p": 16, "q": 17, "r": 18,
    "s": 19, "t": 20, "u": 21, "v": 22, "w": 23, "x": 24, "y": 25, "z": 26, "A": 27,
    "B": 28, "C": 29, "D": 30, "E": 31, "F": 32, "G": 33, "H": 34, "I": 35, "J": 36,
    "K": 37, "L": 38, "M": 39, "N": 40, "O": 41, "P": 42, "Q": 43, "R": 44, "S": 45,
    "T": 46, "U": 47, "V": 48, "W": 49, "X": 50, "Y": 51, "Z": 52
]

let compartments = input.components(separatedBy: .newlines)
    .map {
        let halfLength = $0.count / 2
        return (
            $0.prefix(halfLength),
            $0.suffix(halfLength)
        )
    }

let compartmentSets = compartments
    .map { (Set($0.0), Set($0.1)) }

let sharedItems = compartmentSets
    .map { $0.0.intersection($0.1) }

guard sharedItems.allSatisfy({ $0.count == 1 }) else {
    fatalError()
}

let sharedItemPriorities = sharedItems
    .map { $0.compactMap({ priorities[$0] })[0] }

let totalItemPriorities = sharedItemPriorities.reduce(0, +)

print("""
Part 1 Solution:
    Total Item Priorities: \(totalItemPriorities)
""")

/*:
 ## Part Two

 As you finish identifying the misplaced items, the Elves come to you with another issue.

 For safety, the Elves are divided into groups of three. Every Elf carries a badge that identifies their group. For efficiency, within each group of three Elves, the badge is the **only item type carried by all three Elves**. That is, if a group's badge is item type B, then all three Elves will have item type B somewhere in their rucksack, and at most two of the Elves will be carrying any other item type.

 The problem is that someone forgot to put this year's updated authenticity sticker on the badges. All of the badges need to be pulled out of the rucksacks so the new authenticity stickers can be attached.

 Additionally, nobody wrote down which item type corresponds to each group's badges. The only way to tell which item type is the right one is by finding the one item type that is **common between all three Elves** in each group.

 Every set of three lines in your list corresponds to a single group, but each group can have a different badge item type. So, in the above example, the first group's rucksacks are the first three lines:

 ```
 vJrwpWtwJgWrhcsFMMfFFhFp
 jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
 PmmdzqPrVvPwwTWBwg
 ```

 And the second group's rucksacks are the next three lines:

 ```
 wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
 ttgJtRGJQctTZtZT
 CrZsJsPPZsGzwwsLwLmpwMDw
 ```

 In the first group, the only item type that appears in all three rucksacks is lowercase `r`; this must be their badges. In the second group, their badge item type must be `Z`.

 Priorities for these items must still be found to organize the sticker attachment efforts: here, they are 18 (`r`) for the first group and 52 (`Z`) for the second group. The sum of these is **`70`**.

 Find the item type that corresponds to the badges of each three-Elf group. **What is the sum of the priorities of those item types?**
 */

let rucksackSets = input
    .components(separatedBy: .newlines)
    .map { Set($0) }

guard rucksackSets.count.isMultiple(of: 3) else {
    fatalError("There are not enough groups of rucksacks.")
}

let rucksackGroups = stride(
    from: rucksackSets.startIndex,
    to: rucksackSets.endIndex,
    by: 3
).map {
    Array(rucksackSets[$0..<min($0.advanced(by: 3), rucksackSets.endIndex)])
}

let groupSets = rucksackGroups
    .map { $0[0].intersection($0[1]).intersection($0[2]) }

let groupPriorities = groupSets
    .map { $0.compactMap({ priorities[$0] })[0] }

let totalGroupPriorities = groupPriorities.reduce(0, +)

print("""
Part 2 Solution:
    Total Group Priorities: \(totalGroupPriorities)
""")

//: [Next](@next)
