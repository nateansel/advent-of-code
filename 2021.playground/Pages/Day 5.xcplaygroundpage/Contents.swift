/*:
 [Previous](@previous)

 # Day 5: Hydrothermal Venture

 ## Part One

 You come across a field of [hydrothermal vents](https://en.wikipedia.org/wiki/Hydrothermal_vent) on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

 They tend to form in **lines**; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

 ```
 0,9 -> 5,9
 8,0 -> 0,8
 9,4 -> 3,4
 2,2 -> 2,1
 7,0 -> 7,4
 6,4 -> 2,0
 0,9 -> 2,9
 3,4 -> 1,4
 0,0 -> 8,8
 5,5 -> 8,2
 ```

 Each line of vents is given as a line segment in the format `x1,y1 -> x2,y2` where `x1`,`y1` are the coordinates of one end the line segment and `x2`,`y2` are the coordinates of the other end. These line segments include the points at both ends. In other words:

 - An entry like `1,1 -> 1,3` covers points `1,1`, `1,2`, and `1,3`.
 - An entry like `9,7 -> 7,7` covers points `9,7`, `8,7`, and `7,7`.

 For now, **only consider horizontal and vertical lines**: lines where either `x1 = x2` or `y1 = y2`.

 So, the horizontal and vertical lines from the above list would produce the following diagram:

 ```
 .......1..
 ..1....1..
 ..1....1..
 .......1..
 .112111211
 ..........
 ..........
 ..........
 ..........
 222111....
 ```

 In this diagram, the top left corner is `0,0` and the bottom right corner is `9,9`. Each position is shown as **the number of lines which cover that point** or `.` if no line covers that point. The top-left pair of `1`s, for example, comes from `2,2 -> 2,1`; the very bottom row is formed by the overlapping lines `0,9 -> 5,9` and `0,9 -> 2,9`.

 To avoid the most dangerous areas, you need to determine **the number of points where at least two lines overlap**. In the above example, this is anywhere in the diagram with a `2` or larger - a total of `5` points.

 Consider only horizontal and vertical lines. **At how many points do at least two lines overlap?**
 */

import Foundation

struct Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init?(rawValue: String) {
        let rawInts = rawValue.components(separatedBy: ",").compactMap { Int($0) }
        guard rawInts.count == 2 else { return nil }
        x = rawInts[0]
        y = rawInts[1]
    }
}

struct Line {
    var start: Point
    var end: Point

    var type: Type {
        switch (start.x == end.x, start.y == end.y) {
        case (true, true): return .point
        case (true, false): return .vertical
        case (false, true): return .horizontal
        case (false, false): return .diagonal
        }
    }

    var coverage: [Point] {
        switch type {
        case .point:
            return [start]
        case .vertical:
            return calculateVerticalCoverage()
        case .horizontal:
            return calculateHorizontalCoverage()
        case .diagonal:
            return calculateDiagonalCoverage()
        }
    }

    init?(rawValue: String) {
        let points = rawValue.components(separatedBy: " -> ").compactMap { Point(rawValue: $0) }
        guard points.count == 2 else { return nil }
        start = points[0]
        end = points[1]
    }

    enum `Type`: String {
        case horizontal, vertical, diagonal, point
    }

    private func calculateVerticalCoverage() -> [Point] {
        (min(start.y, end.y)...max(start.y, end.y))
            .map { Point(x: start.x, y: $0) }
    }

    private func calculateHorizontalCoverage() -> [Point] {
        (min(start.x, end.x)...max(start.x, end.x))
            .map { Point(x: $0, y: start.y) }
    }

    private func calculateDiagonalCoverage() -> [Point] {
        let xOffset = (end.x - start.x) > 0 ? 1 : -1
        let yOffset = (end.y - start.y) > 0 ? 1 : -1
        return (0...(max(start.x, end.x) - min(start.x, end.x)))
            .map { Point(x: start.x + ($0 * xOffset), y: start.y + ($0 * yOffset)) }
    }
}

struct Diagram {
    let lines: [Line]

    func calculateCoverageMatrix() -> [[Int]] {
        let maxX = lines.flatMap({ [$0.start.x, $0.end.x] }).max() ?? 0
        let maxY = lines.flatMap({ [$0.start.y, $0.end.y] }).max() ?? 0

        var matrix: [[Int]] = Array(repeating: Array(repeating: 0, count: maxX + 1), count: maxY + 1)

        for line in lines {
            for point in line.coverage {
                matrix[point.y][point.x] += 1
            }
        }

        return matrix
    }
}

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

let PRINT_DIAGRAMS = false

let lines = input.components(separatedBy: .newlines).compactMap { Line(rawValue: $0) }
let puzzle1Diagram = Diagram(lines: lines.filter({ $0.type != .diagonal }))
let puzzle1Matrix = puzzle1Diagram.calculateCoverageMatrix()

print("""
Part 1 Results (horizontal & vertical only):
    Dangerous Points: \(puzzle1Matrix.reduce(0, { $0 + $1.filter({ $0 > 1 }).count }))
""")

if PRINT_DIAGRAMS {
    let puzzle1Description = puzzle1Matrix
        .map { $0.map({ $0 == 0 ? "." : String($0) }).joined(separator: " ") }
        .joined(separator: "\n")
    print("""
        Diagram:
    \(puzzle1Description.components(separatedBy: .newlines).map({ "        \($0)"}).joined(separator: "\n"))
    """)
}

/*:
 ## Part Two

 Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture; you need to also consider **diagonal lines**.

 Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

 - An entry like `1,1 -> 3,3` covers points `1,1`, `2,2`, and `3,3`.
 - An entry like `9,7 -> 7,9` covers points `9,7`, `8,8`, and `7,9`.

 Considering all lines from the above example would now produce the following diagram:

 ```
 1.1....11.
 .111...2..
 ..2.1.111.
 ...1.2.2..
 .112313211
 ...1.2....
 ..1...1...
 .1.....1..
 1.......1.
 222111....
 ```

 You still need to determine **the number of points where at least two lines overlap**. In the above example, this is still anywhere in the diagram with a `2` or larger - now a total of `12` points.

 Consider all of the lines. **At how many points do at least two lines overlap?**
 */

let puzzle2Diagram = Diagram(lines: lines)
let puzzle2Matrix = puzzle2Diagram.calculateCoverageMatrix()

print("""
Part 2 Results (all lines):
    Dangerous Points: \(puzzle2Matrix.reduce(0, { $0 + $1.filter({ $0 > 1 }).count }))
""")

if PRINT_DIAGRAMS {
    let puzzle2Description = puzzle2Matrix
        .map { $0.map({ $0 == 0 ? "." : String($0) }).joined(separator: " ") }
        .joined(separator: "\n")
    print("""
        Diagram:
    \(puzzle2Description.components(separatedBy: .newlines).map({ "        \($0)"}).joined(separator: "\n"))
    """)
}

//: [Next](@next)
