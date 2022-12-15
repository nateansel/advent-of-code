/*:
 [Previous](@previous)

 # 
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int

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
        return Point(x: self.x + x, y: self.y + y)
    }

    func calculatePointsBetween(other: Point) -> [Point] {
        guard self != other else { return [self] }
        if x == other.x {
            if y < other.y {
                return (y...other.y).map { Point(x: x, y: $0) }
            }
            return (other.y...y).map { Point(x: x, y: $0) }
        }
        if x < other.x {
            return (x...other.x).map { Point(x: $0, y: y) }
        }
        return (other.x...x).map { Point(x: $0, y: y) }
    }
}

struct Rock {
    let points: [Point]

    init(points: [Point]) {
        self.points = points
    }

    init(rawValue: String) {
        points = rawValue
            .split(separator: " -> ")
            .map { Point.init(rawValue: String($0)) }
    }

    var allPoints: Set<Point> {
        var allPoints: Set<Point> = []
        for index in points.indices {
            if index == points.indices.last {
                break
            }
            allPoints.formUnion(points[index].calculatePointsBetween(other: points[index + 1]))
        }
        return allPoints
    }
}

let rocks = input
    .components(separatedBy: .newlines)
    .map(Rock.init(rawValue:))

let xValues = rocks
    .flatMap(\.points)
    .map(\.x)
let yValues = rocks
    .flatMap(\.points)
    .map(\.y)
let minX = xValues.min()!
let maxX = xValues.max()!
let minY = yValues.min()!
let maxY = yValues.max()!

enum GridSpace: CustomStringConvertible, Equatable {
    case empty, rock, sand

    var description: String {
        switch self {
        case .empty: return "."
        case .rock: return "#"
        case .sand: return "o"
        }
    }
}

extension Array where Element == [GridSpace] {
    subscript(_ point: Point) -> GridSpace {
        get { self[point.y][point.x] }
        set { self[point.y][point.x] = newValue }
    }
}

let widthOffset = 4
let width = (maxX - minX) + (widthOffset * 2)
let height = (maxY - minY) + (width / 4)

let xOffset = -minX + widthOffset
let yOffset = -minY + (width / 4) - 1

var cave = Array(
    repeating: Array(
        repeating: GridSpace.empty,
        count: width
    ),
    count: height
)

let rockPoints = rocks.reduce(Set<Point>()) { $0.union($1.allPoints) }

print("CAVE: (x: \(cave[0].count), y: \(cave.count))")
for point in rockPoints {
    cave[point.offset(x: xOffset, y: yOffset)] = .rock
}

let sandPosition = Point(x: 500, y: 0)
let offsetSandPosition = sandPosition.offset(x: xOffset, y: 0)
//print(cave.map({ $0.map(\.description).joined() }).joined(separator: "\n"))

func newSandPosition(at point: Point) -> Point? {
    guard cave.indices.contains(point.y + 1) else { return nil }
    if cave[point.offset(x: 0, y: 1)] == .empty {
        return point.offset(x: 0, y: 1)
    } else if cave[point.offset(x: -1, y: 1)] == .empty {
        return point.offset(x: -1, y: 1)
    } else if cave[point.offset(x: 1, y: 1)] == .empty {
        return point.offset(x: 1, y: 1)
    }
    return nil
}

func dropSand(from point: Point) {
    var currentPoint = point
    while let newPoint = newSandPosition(at: currentPoint) {
        currentPoint = newPoint
    }
    cave[currentPoint] = .sand
}

while !cave.last!.contains(.sand) {
    dropSand(from: offsetSandPosition)
}

//print(cave.map({ $0.map(\.description).joined() }).joined(separator: "\n"))

let totalSand = cave
    .flatMap { $0 }
    .filter { $0 == .sand }
    .count
    - 1 // Minus one because of the one overflow sand we allowed

print("""
Part 1 Solution:
    Total Sand Units: \(totalSand)
""")

/*:
 ## Part Two


 */

//var sandPoints: Set<Point> = []
//
//func newSandPositionSet(at point: Point, floor: Int) -> Point? {
//    guard (point.y + 1) < floor else { return nil }
//    let below = point.offset(x: 0, y: 1)
//    let belowLeft = point.offset(x: -1, y: 1)
//    let belowRight = point.offset(x: 1, y: 1)
//    if rockPoints.contains(below) || sandPoints.contains(below) {
//        if rockPoints.contains(belowLeft) || sandPoints.contains(belowLeft) {
//            if rockPoints.contains(belowRight) || sandPoints.contains(belowRight) {
//                return nil
//            }
//            return belowRight
//        }
//        return belowLeft
//    }
//    return below
//}
//
//func dropSandSet(from point: Point) {
//    var currentPoint = point
//    while let newPoint = newSandPositionSet(at: currentPoint, floor: maxY + 2) {
//        currentPoint = newPoint
//    }
//    sandPoints.insert(currentPoint)
//}
//
//while !sandPoints.contains(sandPosition) {
//    dropSandSet(from: sandPosition)
//}

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
            }
        }
    }

    func dropSand(from startingPoint: Point, following previousPath: [Point], floor: Int) -> [Point] {
        var newPath = Array(previousPath.dropLast())
        while !newPath.isEmpty {
            if let newPoint = newValidDropPoint(from: newPath.removeLast(), floor: floor) {
                newPath.append(newPoint)
                var currentPoint = newPoint
                while let point = newValidDropPoint(from: currentPoint, floor: floor) {
                    newPath.append(point)
                    currentPoint = point
                }
                return newPath
            }
        }
        var currentPoint = startingPoint
        newPath = [currentPoint]
        while let point = newValidDropPoint(from: currentPoint, floor: floor) {
            newPath.append(point)
            currentPoint = point
        }
        return newPath
    }

    func newValidDropPoint(from point: Point, floor: Int) -> Point? {
        guard (point.y + 1) < floor else { return nil }
        let below = point.offset(x: 0, y: 1)
        let belowLeft = point.offset(x: -1, y: 1)
        let belowRight = point.offset(x: 1, y: 1)
        if rocks.contains(below) || sand.contains(below) {
            if rocks.contains(belowLeft) || sand.contains(belowLeft) {
                if rocks.contains(belowRight) || sand.contains(belowRight) {
                    return nil
                }
                return belowRight
            }
            return belowLeft
        }
        return below
    }
}

func printSetCave(rocks: Set<Point>, sand: Set<Point>) {
    let maxX = max(rocks.map(\.x).max()!, sand.map(\.x).max()!)
    let minX = min(rocks.map(\.x).min()!, sand.map(\.x).min()!)
    let maxY = max(rocks.map(\.y).max()!, sand.map(\.y).max()!)
    let minY = min(rocks.map(\.y).min()!, sand.map(\.y).min()!)

    var toPrint = ""
    for y in (minY - 4)...(maxY + 4) {
        for x in (minX - 4)...(maxX + 4) {
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
    print(toPrint)
}

let rocksPointsNew = rocks.reduce(Set<Point>(), { $0.union($1.allPoints) })
let caveNew = Cave(rocks: rocksPointsNew)
caveNew.fillCave(from: Point(x: 500, y: 0), floor: maxY + 2)
print(caveNew)

//printSetCave(rocks: rockPoints, sand: sandPoints)

print("""
Part 2 Solution:
    Total Sand Units: \(caveNew.sand.count)
""")

//: [Next](@next)
