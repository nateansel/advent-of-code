/*:
 [Previous](@previous)

 # Day 9: Smoke Basin

 ## Part One

 These caves seem to be [lava tubes](https://en.wikipedia.org/wiki/Lava_tube). Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.

 If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).

 Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:

 ```
 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 ```

 Each number corresponds to the height of a particular location, where `9` is the highest and `0` is the lowest a location can be.

 Your first goal is to find the **low points** - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)

 In the above example, there are **four** low points, all highlighted: two are in the first row (a `1` and a `0`), one is in the third row (a `5`), and one is in the bottom row (also a `5`). All other locations on the heightmap have some lower adjacent location, and so are not low points.

 ```
 2-9994321-
 3987894921
 98-6789892
 8767896789
 989996-678
 ```

 The **risk level** of a low point is **`1` plus its height**. In the above example, the risk levels of the low points are `2`, `1`, `6`, and `6`. The sum of the risk levels of all low points in the heightmap is therefore **`15`**.

 Find all of the low points on your heightmap. **What is the sum of the risk levels of all low points on your heightmap?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Point: Equatable, CustomDebugStringConvertible {
    let row: Int
    let column: Int

    var above: Point { Point(row: row.advanced(by: -1), column: column) }
    var below: Point { Point(row: row.advanced(by: 1), column: column) }
    var left: Point { Point(row: row, column: column.advanced(by: -1)) }
    var right: Point { Point(row: row, column: column.advanced(by: 1)) }

    var surrounding: [Point] { [above, below, left, right] }

    var debugDescription: String {
        "(\(String(format: "%02d", row)), \(String(format: "%02d", column)))"
    }
}

struct OceanFloor {
    var grid: [[Int]]

    init(grid: [[Int]]) {
        self.grid = grid
    }

    init(rawValue: String) {
        grid = rawValue
            .components(separatedBy: .newlines)
            .map { $0.compactMap({ Int("\($0)") }) }
    }

    /// Finds all the low points in this `OceanFloor` and returns their values.
    func findLowPoints() -> [Int] {
        locateLowPoints().compactMap { number(at: $0) }
    }

    /// Locates all of the low points in `grid` and returns the locations of those values.
    private func locateLowPoints() -> [Point] {
        var lowPoints: [Point] = []
        for i in grid.indices {
            for j in grid[i].indices {
                let point = Point(row: i, column: j)
                if isNumberLowPoint(at: point) {
                    lowPoints.append(point)
                }
            }
        }
        return lowPoints
    }

    /// Determines if the given point is a low point (surrounded by values higher than itself).
    private func isNumberLowPoint(at point: Point) -> Bool {
        guard let value = number(at: point) else { return false }
        if let above = number(at: point.above), above <= value {
            return false
        }
        if let below = number(at: point.below), below <= value {
            return false
        }
        if let left = number(at: point.left), left <= value {
            return false
        }
        if let right = number(at: point.right), right <= value {
            return false
        }
        return true
    }

    /// Checks if the given point exists in `grid`. Used to check for out-of-bounds points
    /// before attempting to access the number in that location.
    private func verify(point: Point) -> Bool {
        grid.indices.contains(point.row) && (grid.first?.indices.contains(point.column) ?? false)
    }

    /// Returns the number at the given point, or nil if the point is out-of-bounds.
    private func number(at point: Point) -> Int? {
        verify(point: point) ? grid[point.row][point.column] : nil
    }
}

let floor = OceanFloor(rawValue: input)
let lowPoints = floor.findLowPoints()
let riskLevel = lowPoints.reduce(0) { $0 + $1 + 1 }

print("""
Part 1 Solution:
    Total number of Low Points: \(lowPoints.count)
    Risk Level: \(riskLevel)
""")

/*:
 ## Part Two

 Next, you need to find the largest basins so you know what areas are most important to avoid.

 A **basin** is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

 The **size** of a basin is the number of locations within the basin, including the low point. The example above has four basins.

 The top-left basin, size `3`:

 ```
 --99943210
 -987894921
 9856789892
 8767896789
 9899965678
 ```

 The top-right basin, size `9`:

 ```
 21999-----
 398789-9--
 985678989-
 8767896789
 9899965678
 ```

 The middle basin, size `14`:

 ```
 2199943210
 39---94921
 9-----9892
 -----96789
 9-99965678
 ```

 The bottom-right basin, size `9`:

 ```
 2199943210
 3987894921
 9856789-92
 876789---9
 98999-----
 ```

 Find the three largest basins and multiply their sizes together. In the above example, this is `9 * 14 * 9 = 1134`.

 **What do you get if you multiply together the sizes of the three largest basins?**
 */

extension OceanFloor {
    /// Locates the basins in the grid and returns an array of the coordinates of each of the
    /// elements and returns the locations of each of the spaces in each basin.
    func locateBasins() -> [[Point]] {
        let lowPoints = locateLowPoints()
        var basins: [[Point]] = []

        // Use low points as our starting points since they are guarenteed to exist in a basin.
        for point in lowPoints {
            // Make sure the low point wasn't already included in another basin.
            if !basins.contains(where: { $0.contains(point) }) {
                basins.append(locatePointsInBasin(with: point))
            }
        }
        return basins
    }

    /// Locates all the points in a basin with a given starting point.
    private func locatePointsInBasin(with startingPoint: Point) -> [Point] {
        var verifiedPoints: [Point] = []
        var pointsToCheck: [Point] = [startingPoint]

        while !pointsToCheck.isEmpty {
            var newPointsToCheck: [Point] = []
            for point in pointsToCheck {
                if let number = number(at: point),
                    number != 9 && !verifiedPoints.contains(point) {
                    verifiedPoints.append(point)
                    newPointsToCheck.append(contentsOf: point.surrounding)
                }
            }
            pointsToCheck = newPointsToCheck
        }
        return verifiedPoints
    }
}

let basins = floor.locateBasins()
let largestBasins = basins.sorted(by: { $0.count > $1.count }).dropLast(basins.count - 3)

print("""
Part 2 Solution:
    Total number of basins: \(basins.count)
    Three largest basins (sizes): \(largestBasins.map({ $0.count }))
    Solution: \(largestBasins.reduce(1, { $0 * $1.count }))
""")

//: [Next](@next)
