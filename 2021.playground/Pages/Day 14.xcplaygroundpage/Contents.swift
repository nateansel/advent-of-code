/*:
 [Previous](@previous)

 # Day 14: Extended Polymerization

 The incredible pressures at this depth are starting to put a strain on your submarine. The submarine has [polymerization](https://en.wikipedia.org/wiki/Polymerization) equipment that would produce suitable materials to reinforce the submarine, and the nearby volcanically-active caves should even have the necessary input elements in sufficient quantities.

 The submarine manual contains instructions for finding the optimal polymer formula; specifically, it offers a **polymer template** and a list of **pair insertion** rules (your puzzle input). You just need to work out what polymer would result after repeating the pair insertion process a few times.

 For example:

 ```
 NNCB

 CH -> B
 HH -> N
 CB -> H
 NH -> C
 HB -> C
 HC -> B
 HN -> C
 NN -> C
 BH -> H
 NC -> B
 NB -> B
 BN -> B
 BB -> N
 BC -> B
 CC -> N
 CN -> C
 ```

 The first line is the **polymer template** - this is the starting point of the process.

 The following section defines the pair insertion rules. A rule like `AB -> C` means that when elements `A` and `B` are immediately adjacent, element `C` should be inserted between them. These insertions all happen simultaneously.

 So, starting with the polymer template `NNCB`, the first step simultaneously considers all three pairs:

 - The first pair (`NN`) matches the rule `NN -> C`, so element `C` is inserted between the first `N` and the second `N`.
 - The second pair (`NC`) matches the rule `NC -> B`, so element `B` is inserted between the `N` and the `C`.
 - The third pair (`CB`) matches the rule `CB -> H`, so element `H` is inserted between the `C` and the `B`.

 Note that these pairs overlap: the second element of one pair is the first element of the next pair. Also, because all pairs are considered simultaneously, inserted elements are not considered to be part of a pair until the next step.

 After the first step of this process, the polymer becomes `NCNBCHB`.

 Here are the results of a few steps using the above rules:

 ```
 Template:     NNCB
 After step 1: NCNBCHB
 After step 2: NBCCNBBBCBHCB
 After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
 After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
 ```

 This polymer grows quickly. After step 5, it has length 97; After step 10, it has length 3073. After step 10, `B` occurs 1749 times, `C` occurs 298 times, `H` occurs 161 times, and `N` occurs 865 times; taking the quantity of the most common element (`B`, 1749) and subtracting the quantity of the least common element (`H`, 161) produces `1749 - 161 = 1588`.

 Apply 10 steps of pair insertion to the polymer template and find the most and least common elements in the result. **What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Polymer {
    var pairs: [String: Int] = [:]
    var lastCharacter: Character = Character(" ")

    init(pairs: [String: Int], lastCharacter: Character) {
        self.pairs = pairs
        self.lastCharacter = lastCharacter
    }

    init(rawValue: String) {
        var pairs = Array(repeating: "..", count: rawValue.count - 1)
        let elements = Array(rawValue)
        for (index, character) in elements.enumerated() {
            let nextIndex = index.advanced(by: 1)
            if nextIndex < elements.count {
                pairs[index] = String([character, elements[nextIndex]])
            }
        }
        for pair in pairs {
            self.pairs[pair, default: 0] += 1
        }
        lastCharacter = elements.last!
    }

    func nextStep(for rules: [String: Character]) -> Polymer {
        var count = pairs
        var newCount: [String: Int] = [:]
        for key in rules.keys {
            if let ruleCount = count[key], ruleCount != 0 {
                count[key] = 0
                let newPair1 = "\(key.first!)\(rules[key]!)"
                let newPair2 = "\(rules[key]!)\(key.last!)"
                newCount[newPair1, default: 0] += ruleCount
                newCount[newPair2, default: 0] += ruleCount
            }
        }
        for key in newCount.keys {
            count[key, default: 0] += newCount[key]!
        }
        return Polymer(pairs: count, lastCharacter: lastCharacter)
    }

    func advanced(by steps: Int, for rules: [String: Character]) -> Polymer {
        var currentPolymer = self
        for _ in 0..<steps {
            currentPolymer = currentPolymer.nextStep(for: rules)
        }
        return currentPolymer
    }

    func countElements() -> [Character: Int] {
        var count: [Character: Int] = [:]
        for key in pairs.keys {
            count[key.first!, default: 0] += pairs[key]!
        }
        count[lastCharacter, default: 0] += 1
        return count
    }
}

func parse(input: String) -> (Polymer, [String: Character]) {
    var newPolymer: String = ""
    var rules: [String: Character] = [:]
    for line in input.components(separatedBy: .newlines) {
        if line.isEmpty {
            continue
        } else if line.contains("->") {
            let components = line.components(separatedBy: " -> ")
            if components.count == 2 {
                rules[components[0]] = components[1].first!
            } else {
                fatalError("INCORRECT RULE")
            }
        } else {
            newPolymer = line
        }
    }
    return (Polymer(rawValue: newPolymer), rules)
}

let (polymer, rules) = parse(input: input)

let after10StepsPolymer = polymer.advanced(by: 10, for: rules)
let after10StepsElementsCount = after10StepsPolymer.countElements()
let after10StepsMaxElement = after10StepsElementsCount.max(by: { $0.value < $1.value })!.value
let after10StepsMinElement = after10StepsElementsCount.min(by: { $0.value < $1.value })!.value

print("""
Part 1 Solution:
    Polymer element counts after 10 steps:
\(after10StepsElementsCount.map({ "        \($0.key): \($0.value)" }).joined(separator: "\n"))
    Polymer max minus min: \(after10StepsMaxElement - after10StepsMinElement)
""")

/*:
 ## Part Two

 The resulting polymer isn't nearly strong enough to reinforce the submarine. You'll need to run more steps of the pair insertion process; a total of **40 steps** should do it.

 In the above example, the most common element is `B` (occurring `2192039569602` times) and the least common element is `H` (occurring `3849876073` times); subtracting these produces **`2188189693529`**.

 Apply **40** steps of pair insertion to the polymer template and find the most and least common elements in the result. **What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?**
 */

let after40StepsPolymer = polymer.advanced(by: 40, for: rules)
let after40StepsElementsCount = after40StepsPolymer.countElements()
let after40StepsMaxElement = after40StepsElementsCount.max(by: { $0.value < $1.value })!.value
let after40StepsMinElement = after40StepsElementsCount.min(by: { $0.value < $1.value })!.value

print("""
Part 2 Solution:
    Polymer element counts after 10 steps:
\(after40StepsElementsCount.map({ "        \($0.key): \($0.value)" }).joined(separator: "\n"))
    Polymer max minus min: \(after40StepsMaxElement - after40StepsMinElement)
""")

//: [Next](@next)
