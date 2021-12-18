/*:
 [Previous](@previous)

 # Day 8: Seven Segment Search
 
 ## Part One
 
 You barely reach the safety of the cave when the whale smashes into the cave mouth, collapsing it. Sensors indicate another exit to this cave at a much greater depth, so you have no choice but to press on.

 As your submarine slowly makes its way through the cave system, you notice that the four-digit [seven-segment displays](https://en.wikipedia.org/wiki/Seven-segment_display) in your submarine are malfunctioning; they must have been damaged during the escape. You'll be in a lot of trouble without them, so you'd better figure out what's wrong.

 Each digit of a seven-segment display is rendered by turning on or off any of seven segments named a through g:

 ```
   0:      1:      2:      3:      4:
  aaaa    ....    aaaa    aaaa    ....
 b    c  .    c  .    c  .    c  b    c
 b    c  .    c  .    c  .    c  b    c
  ....    ....    dddd    dddd    dddd
 e    f  .    f  e    .  .    f  .    f
 e    f  .    f  e    .  .    f  .    f
  gggg    ....    gggg    gggg    ....

   5:      6:      7:      8:      9:
  aaaa    aaaa    aaaa    aaaa    aaaa
 b    .  b    .  .    c  b    c  b    c
 b    .  b    .  .    c  b    c  b    c
  dddd    dddd    ....    dddd    dddd
 .    f  e    f  .    f  e    f  .    f
 .    f  e    f  .    f  e    f  .    f
  gggg    gggg    ....    gggg    gggg
 ```
 
 So, to render a `1`, only segments `c` and `f` would be turned on; the rest would be off. To render a `7`, only segments `a`, `c`, and `f` would be turned on.

 The problem is that the signals which control the segments have been mixed up on each display. The submarine is still trying to display numbers by producing output on signal wires a through g, but those wires are connected to segments **randomly**. Worse, the wire/segment connections are mixed up separately for each four-digit display! (All of the digits **within** a display use the same connections, though.)

 So, you might know that only signal wires b and g are turned on, but that doesn't mean segments b and g are turned on: the only digit that uses two segments is 1, so it must mean segments c and f are meant to be on. With just that information, you still can't tell which wire (b/g) goes to which segment (c/f). For that, you'll need to collect more information.

 For each display, you watch the changing signals for a while, make a note of all ten unique signal patterns you see, and then write down a single four digit output value (your puzzle input). Using the signal patterns, you should be able to work out which pattern corresponds to which digit.

 For example, here is what you might see in a single entry in your notes:

 acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
 cdfeb fcadb cdfeb cdbaf
 (The entry is wrapped here to two lines so it fits; in your notes, it will all be on a single line.)

 Each entry consists of ten unique signal patterns, a | delimiter, and finally the four digit output value. Within an entry, the same wire/segment connections are used (but you don't know what the connections actually are). The unique signal patterns correspond to the ten different ways the submarine tries to render a digit using the current wire/segment connections. Because 7 is the only digit that uses three segments, dab in the above example means that to render a 7, signal lines d, a, and b are on. Because 4 is the only digit that uses four segments, eafb means that to render a 4, signal lines e, a, f, and b are on.

 Using this information, you should be able to work out which combination of signal wires corresponds to each of the ten digits. Then, you can decode the four digit output value. Unfortunately, in the above example, all of the digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and are more difficult to deduce.

 For now, focus on the easy digits. Consider this larger example:

 ```
 be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |
 fdgacbe cefdb cefbgd gcbe
 edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |
 fcgedb cgb dgebacf gc
 fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |
 cg cg fdcagb cbg
 fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |
 efabcd cedba gadfec cb
 aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |
 gecf egdcabf bgf bfgea
 fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |
 gebdcfa ecba ca fadegcb
 dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
 cefg dcbef fcge gbcadfe
 bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |
 ed bcgafe cdgba cbgef
 egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |
 gbdfcae bgc cg cgb
 gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |
 fgae cfgab fg bagce
 ```
 
 Because the digits `1`, `4`, `7`, and `8` each use a unique number of segments, you should be able to tell which combinations of signals correspond to those digits. Counting **only digits in the output values** (the part after | on each line), in the above example, there are 26 instances of digits that use a unique number of segments (highlighted above).

 **In the output values, how many times do digits `1`, `4`, `7`, or `8` appear?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

let lines = input
    .components(separatedBy: .newlines)
    .map { $0.components(separatedBy: .whitespaces).filter({ $0 != "|" }) }

let count = lines.reduce(0) {
    $0 + $1.dropFirst(10).filter({ [2, 3, 4, 7].contains($0.count) }).count
}

print("""
Part 1 Solution:
    1, 4, 7, and 8 appear: \(count)
""")

/*:
 ## Part Two

 Through a little deduction, you should now be able to determine the remaining digits. Consider again the first example above:

 ```
 acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
 cdfeb fcadb cdfeb cdbaf
 ```
 
 After some careful analysis, the mapping between signal wires and segments only make sense in the following configuration:

 ```
  dddd
 e    a
 e    a
  ffff
 g    b
 g    b
  cccc
 ```

 So, the unique signal patterns would correspond to the following digits:

 - `acedgfb`: `8`
 - `cdfbe`: `5`
 - `gcdfa`: `2`
 - `fbcad`: `3`
 - `dab`: `7`
 - `cefabd`: `9`
 - `cdfgeb`: `6`
 - `eafb`: `4`
 - `cagedb`: `0`
 - `ab`: `1`

 Then, the four digits of the output value can be decoded:

 - `cdfeb`: **`5`**
 - `fcadb`: **`3`**
 - `cdfeb`: **`5`**
 - `cdbaf`: **`3`**

 Therefore, the output value for this entry is **`5353`**.

 Following this same process for each entry in the second, larger example above, the output value of each entry can be determined:

 - `fdgacbe cefdb cefbgd gcbe`: `8394`
 - `fcgedb cgb dgebacf gc`: `9781`
 - `cg cg fdcagb cbg`: `1197`
 - `efabcd cedba gadfec cb`: `9361`
 - `gecf egdcabf bgf bfgea`: `4873`
 - `gebdcfa ecba ca fadegcb`: `8418`
 - `cefg dcbef fcge gbcadfe`: `4548`
 - `ed bcgafe cdgba cbgef`: `1625`
 - `gbdfcae bgc cg cgb`: `8717`
 - `fgae cfgab fg bagce`: `4315`

 Adding all of the output values in this larger example produces **`61229`**.

 For each entry, determine all of the wire/segment connections and decode the four-digit output values. **What do you get if you add up all of the output values?**
 */

/// Calculates the wire mapping for the given input.
func determineWireMapping(with input: [Set<Character>]) -> [Character: Character] {
    var wireMapping: [Character: Character] = [:]
    var oneWires: Set<Character>? = nil
    var fourWires: Set<Character>? = nil
    var sevenWires: Set<Character>? = nil

    // Gather guaranteed inputs
    if let one = input.filter({ $0.count == 2 }).first {
        oneWires = one
    }
    if let four = input.filter({ $0.count == 4 }).first {
        fourWires = four
    }
    if let seven = input.filter({ $0.count == 3 }).first {
        sevenWires = seven
    }

    if let one = oneWires, let seven = sevenWires {
        wireMapping["a"] = seven.filter({ !one.contains($0) }).first
    }
    if let one = oneWires, let three = input
        .filter({ $0.count == 5 && $0.isSuperset(of: one) }).first {
        let topMiddleBottom = three.subtracting(one)
        if let four = fourWires {
            wireMapping["d"] = topMiddleBottom.intersection(four).first
            if let d = wireMapping["d"] {
                wireMapping["b"] = four.subtracting(one.union(Set([d]))).first
            }
        }
        if let a = wireMapping["a"], let d = wireMapping["d"] {
            wireMapping["g"] = topMiddleBottom.subtracting(Set([a, d])).first
        }
    }
    if let a = wireMapping["a"],
       let b = wireMapping["b"],
       let d = wireMapping["d"],
       let g = wireMapping["g"] {
        if let five = input
            .filter({ $0.count == 5 })
            .filter({ Set($0).subtracting(Set([a, b, d, g])).count == 1 })
            .first {
            if let one = oneWires {
                let cSet = Set(one).subtracting(Set(five))
                wireMapping["c"] = cSet.first
                wireMapping["f"] = one.subtracting(cSet).first
            }
        }
    }

    let eightSet: Set<Character> = Set(["a", "b", "c", "d", "e", "f", "g"])
    let missingSet = eightSet.subtracting(Set(wireMapping.keys))
    if missingSet.count == 1 {
        wireMapping[missingSet.first!] = eightSet.subtracting(Set(wireMapping.values)).first
    }

    var reversedMapping: [Character: Character] = [:]
    for key in wireMapping.keys {
        reversedMapping[wireMapping[key]!] = key
    }
    return reversedMapping
}

let numericMapping = [
    "cf": 1,
    "acdeg": 2,
    "acdfg": 3,
    "bcdf": 4,
    "abdfg": 5,
    "abdefg": 6,
    "acf": 7,
    "abcdefg": 8,
    "abcdfg": 9,
    "abcefg": 0,
]

func decypherNumericValues(for input: [Set<Character>], with wireMapping: [Character: Character]) -> [Int] {
    var numericValues: [Int] = []
    for value in input
            .map({ $0.map({ wireMapping[$0]! }) })
            .map({ String($0.sorted(by: <)) }) {
        if let numericValue = numericMapping[value] {
            numericValues.append(numericValue)
        } else {
            print("ERROR: Value not found for: \(value)")
        }
    }
    return numericValues
}

let sum = lines.reduce(0) { sum, line in
    let lineSets = line.map({ Set($0) })
    let wireMapping = determineWireMapping(with: lineSets)
    let numericValues = decypherNumericValues(for: lineSets, with: wireMapping)
    let number = Int(numericValues.dropFirst(10).map({ String($0) }).joined(separator: "")) ?? 0
    return sum + number
}

print(sum)

//: [Next](@next)
