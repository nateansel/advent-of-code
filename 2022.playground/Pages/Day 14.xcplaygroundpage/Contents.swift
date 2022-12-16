/*:
 [Previous](@previous)

 # 
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Point: CustomStringConvertible, Equatable, Hashable {
    let x: Int
    let y: Int

    var description: String {
        "(\(x), \(y))"
    }

    var dropPositions: [Point] {
        [
            Point(x: x, y: y + 1),
            Point(x: x - 1, y: y + 1),
            Point(x: x + 1, y: y + 1),
        ]
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(rawValue: String) {
        let components = rawValue.split(separator: ",")
        x = Int(components[0])!
        y = Int(components[1])!
    }

    func offset(x: Int, y: Int) -> Point {
        Point(x: self.x + x, y: self.y + y)
    }

    func calculatePointsBetween(other: Point) -> [Point] {
        stride(from: x, through: other.x, by: (x < other.x) ? 1 : -1 ).flatMap { x in
            stride(from: y, through: other.y, by: (y < other.y) ? 1 : -1).map { y in
                Point(x: x, y: y)
            }
        }
    }
}

struct Rock {
    let points: [Point]

    init(rawValue: String) {
        points = rawValue
            .split(separator: " -> ")
            .map { Point(rawValue: String($0)) }
    }

    var allPoints: Set<Point> {
        zip(points.dropLast(), points.dropFirst())
            .map { Set($0.0.calculatePointsBetween(other: $0.1)) }
            .reduce(Set<Point>(), { $0.union($1) })
    }
}

class Cave: CustomStringConvertible {
    var rocks: Set<Point>
    var sand: Set<Point>

    var description: String {
        let maxX = max(rocks.map(\.x).max() ?? 0, sand.map(\.x).max() ?? 0)
        let minX = min(rocks.map(\.x).min() ?? 0, sand.map(\.x).min() ?? 0)
        let maxY = max(rocks.map(\.y).max() ?? 0, sand.map(\.y).max() ?? 0)
        let minY = min(rocks.map(\.y).min() ?? 0, sand.map(\.y).min() ?? 0)

        var toPrint = ""
        for y in (minY)...(maxY) {
            for x in (minX - 2)...(maxX + 2) {
                let point = Point(x: x, y: y)
                if sand.contains(point) {
                    toPrint += "o"
                } else if rocks.contains(point) {
                    toPrint += "#"
                } else {
                    toPrint += "."
                }
            }
            toPrint += "\n"
        }
        return toPrint
    }

    init(rocks: Set<Point>, sand: Set<Point> = []) {
        self.rocks = rocks
        self.sand = sand
    }

    init(rawValue: String) {
        rocks = rawValue
            .components(separatedBy: .newlines)
            .map(Rock.init(rawValue:))
            .map(\.allPoints)
            .reduce(Set<Point>(), { $0.union($1) })
        sand = []
    }

    // Point Calculations

    /// Drop a unit of sand from the starting point, attempting to follow the previous unit of sand's path.
    ///
    /// Following the previous path is meant to reduce the number of comparisons calculated for each consecutive drop.
    func dropSand(from startingPoint: Point, following previousPath: [Point], floor: Int) -> [Point] {
        var newPath = previousPath.dropLast(while: { newValidDropPoint(from: $0, floor: floor) == nil} )
        if newPath.isEmpty {
            newPath.append(startingPoint)
        }
        while let point = newValidDropPoint(from: newPath.last!, floor: floor) {
            newPath.append(point)
        }
        return Array(newPath)
    }

    func newValidDropPoint(from point: Point, floor: Int) -> Point? {
        guard (point.y + 1) < floor else { return nil }
        for dropPoint in point.dropPositions {
            if !sand.contains(dropPoint) && !rocks.contains(dropPoint) {
                return dropPoint
            }
        }
        return nil
    }

    // Simulations

    func pileOnRocks(from startingPoint: Point) {
        guard let falseFloor = rocks.map(\.y).max()?.advanced(by: 1) else { return }
        var previousSandPath: [Point] = []

        while !sand.contains(where: { $0.y == falseFloor - 1 }) {
            previousSandPath = dropSand(
                from: startingPoint,
                following: previousSandPath,
                floor: falseFloor
            )
            if let point = previousSandPath.last {
                sand.insert(point)
            } else {
                fatalError("Condition for breaking from while loop not met while piling on rocks.")
            }
        }
        if let lastPoint = sand.first(where: { $0.y == falseFloor - 1 }) {
            sand.remove(lastPoint)
        }
    }

    func fillCave(from startingPoint: Point, floor: Int) {
        var previousSandPath: [Point] = []
        while !sand.contains(startingPoint) {
            previousSandPath = dropSand(
                from: startingPoint,
                following: previousSandPath,
                floor: floor
            )
            if let point = previousSandPath.last {
                sand.insert(point)
            } else {
                fatalError("Condition for breaking from while loop not met while filling cave.")
            }
        }
    }
}

let cave = Cave(rawValue: input)
let maxY = cave.rocks
    .map(\.y)
    .max() ?? 0
let sandDropPoint = Point(x: 500, y: 0)

cave.pileOnRocks(from: sandDropPoint)

print("""
Part 1 Solution:
    Total Sand Units: \(cave.sand.count)
""")

/*:
 ## Part Two


 */

cave.fillCave(from: sandDropPoint, floor: maxY + 2)

print("""
Part 2 Solution:
    Total Sand Units: \(cave.sand.count)
""")

//: [Next](@next)
