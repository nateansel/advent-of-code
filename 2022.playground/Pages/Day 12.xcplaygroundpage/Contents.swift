/*:
 [Previous](@previous)

 # Day 12: Hill Climbing Algorithm

 ## Part One

 You try contacting the Elves using your handheld device, but the river you're following must be too low to get a decent signal.

 You ask the device for a heightmap of the surrounding area (your puzzle input). The heightmap shows the local area from above broken into a grid; the elevation of each square of the grid is given by a single lowercase letter, where `a` is the lowest elevation, `b` is the next-lowest, and so on up to the highest elevation, `z`.

 Also included on the heightmap are marks for your current position (`S`) and the location that should get the best signal (`E`). Your current position (`S`) has elevation `a`, and the location that should get the best signal (`E`) has elevation `z`.

 You'd like to reach `E`, but to save energy, you should do it in **as few steps as possible**. During each step, you can move exactly one square up, down, left, or right. To avoid needing to get out your climbing gear, the elevation of the destination square can be **at most one higher** than the elevation of your current square; that is, if your current elevation is `m`, you could step to elevation `n`, but not to elevation `o`. (This also means that the elevation of the destination square can be much lower than the elevation of your current square.)

 For example:

 ```
 Sabqponm
 abcryxxl
 accszExk
 acctuvwj
 abdefghi
 ```

 Here, you start in the top-left corner; your goal is near the middle. You could start by moving down or right, but eventually you'll need to head toward the `e` at the bottom. From there, you can spiral around to the goal:

 ```
 v..v<<<<
 >v.vv<<^
 .>vv>E^^
 ..v>>>^^
 ..>>>>>^
 ```

 In the above diagram, the symbols indicate whether the path exits each square moving up (`^`), down (`v`), left (`<`), or right (`>`). The location that should get the best signal is still `E`, and `.` marks unvisited squares.

 This path reaches the goal in **`31`** steps, the fewest possible.

 **What is the fewest steps required to move from your current position to the location that should get the best signal?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Point: Equatable, Hashable {
    let row: Int
    let column: Int

    static let zero = Point(row: 0, column: 0)
}

extension Array where Element == [Int] {
    subscript(_ point: Point) -> Int {
        get { self[point.row][point.column] }
        set { self[point.row][point.column] = newValue }
    }
}

extension Array where Element == [Character] {
    subscript(_ point: Point) -> Character {
        get { self[point.row][point.column] }
        set { self[point.row][point.column] = newValue }
    }
}

func value(for character: Character) -> Int {
    if character == "S" {
        return 1
    } else if character == "E" {
        return 26
    }
    return Int(character.asciiValue!) - 96
}

func findStartingPositions(in grid: [[Character]], allowingAllLowAreas: Bool) -> [Point] {
    var startingPositions: [Point] = []
    for row in grid.indices {
        for column in grid[row].indices {
            if grid[row][column] == "S" || (allowingAllLowAreas && grid[row][column] == "a") {
                startingPositions.append(Point(row: row, column: column))
            }
        }
    }
    return startingPositions
}

func findEndPosition(in grid: [[Character]]) -> Point {
    for row in grid.indices {
        for column in grid[row].indices {
            if grid[row][column] == "E" {
                return Point(row: row, column: column)
            }
        }
    }
    fatalError()
}

func calculateShortestPath(
    from startingPositions: [Point],
    to end: Point,
    in grid: [[Int]],
    reference: [[Character]]
) -> Int {
    let rowIndices = grid.indices
    let columnIndices = grid[0].indices
    var search: [(Point, Int)] = startingPositions.map { ($0, 0) }
    var visited: Set<Point> = []

    while !search.isEmpty {
        search.sort(by: { $0.1 < $1.1 })
        let (point, pathLength) = search.removeFirst()
        guard !visited.contains(point) else { continue }

        visited.insert(point)

        if point == end {
            return pathLength
        }

        for (deltaRow, deltaColumn) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
            let evaluatingPoint = Point(
                row: point.row + deltaRow,
                column: point.column + deltaColumn
            )
            if rowIndices.contains(evaluatingPoint.row)
                && columnIndices.contains(evaluatingPoint.column)
                && grid[evaluatingPoint] <= (grid[point] + 1) {
                search.append((evaluatingPoint, pathLength + 1))
            }
        }
    }
    return -1
}

let characterGrid = input
    .components(separatedBy: .newlines)
    .map({ $0.map({ $0 }) })

let grid = characterGrid
    .map({ $0.map({ value(for: $0) }) })

let start = findStartingPositions(in: characterGrid, allowingAllLowAreas: false)
let end = findEndPosition(in: characterGrid)

let shortestPath = calculateShortestPath(from: start, to: end, in: grid, reference: characterGrid)

print("""
Part 1 Solution:
    Shortest Path: \(shortestPath)
""")

/*:
 ## Part Two

 As you walk up the hill, you suspect that the Elves will want to turn this into a hiking trail. The beginning isn't very scenic, though; perhaps you can find a better starting point.

 To maximize exercise while hiking, the trail should start as low as possible: elevation `a`. The goal is still the square marked `E`. However, the trail should still be direct, taking the fewest steps to reach its goal. So, you'll need to find the shortest path from **any square at elevation `a`** to the square marked `E`.

 Again consider the example from above:

 ```
 Sabqponm
 abcryxxl
 accszExk
 acctuvwj
 abdefghi
 ```

 Now, there are six choices for starting position (five marked `a`, plus the square marked `S` that counts as being at elevation `a`). If you start at the bottom-left square, you can reach the goal most quickly:

 ```
 ...v<<<<
 ...vv<<^
 ...v>E^^
 .>v>>>^^
 >^>>>>>^
 ```

 This path reaches the goal in only **`29`** steps, the fewest possible.

 **What is the fewest steps required to move starting from any square with elevation a to the location that should get the best signal?**
 */

let points = findStartingPositions(in: characterGrid, allowingAllLowAreas: true)
let shortestTrail = calculateShortestPath(from: points, to: end, in: grid, reference: characterGrid)

print("""
Part 2 Solution:
    Shortest Trail: \(shortestTrail)
""")

//: [Next](@next)
