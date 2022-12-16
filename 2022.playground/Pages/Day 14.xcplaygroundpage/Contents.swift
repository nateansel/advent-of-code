/*:
 [Previous](@previous)

 # Day 14: Regolith Reservoir

 ## Part One

 The distress signal leads you to a giant waterfall! Actually, hang on - the signal seems like it's coming from the waterfall itself, and that doesn't make any sense. However, you do notice a little path that leads **behind** the waterfall.

 Correction: the distress signal leads you behind a giant waterfall! There seems to be a large cave system here, and the signal definitely leads further inside.

 As you begin to make your way deeper underground, you feel the ground rumble for a moment. Sand begins pouring into the cave! If you don't quickly figure out where the sand is going, you could quickly become trapped!

 Fortunately, your [familiarity](https://adventofcode.com/2018/day/17) with analyzing the path of falling material will come in handy here. You scan a two-dimensional vertical slice of the cave above you (your puzzle input) and discover that it is mostly air with structures made of **rock**.

 Your scan traces the path of each solid rock structure and reports the x,y coordinates that form the shape of the path, where x represents distance to the right and y represents distance down. Each path appears as a single line of text in your scan. After the first point of each path, each point indicates the end of a straight horizontal or vertical line to be drawn from the previous point. For example:

 ```
 498,4 -> 498,6 -> 496,6
 503,4 -> 502,4 -> 502,9 -> 494,9
 ```

 This scan means that there are two paths of rock; the first path consists of two straight lines, and the second path consists of three straight lines. (Specifically, the first path consists of a line of rock from `498,4` through `498,6` and another line of rock from `498,6` through `496,6`.)

 The sand is pouring into the cave from point `500,0`.

 Drawing rock as `#`, air as `.`, and the source of the sand as `+`, this becomes:

 ```
   4     5  5
   9     0  0
   4     0  3
 0 ......+...
 1 ..........
 2 ..........
 3 ..........
 4 ....#...##
 5 ....#...#.
 6 ..###...#.
 7 ........#.
 8 ........#.
 9 #########.
 ```

 Sand is produced **one unit at a time**, and the next unit of sand is not produced until the previous unit of sand **comes to rest**. A unit of sand is large enough to fill one tile of air in your scan.

 A unit of sand always falls **down one step** if possible. If the tile immediately below is blocked (by rock or sand), the unit of sand attempts to instead move diagonally **one step down and to the left**. If that tile is blocked, the unit of sand attempts to instead move diagonally **one step down and to the right**. Sand keeps moving as long as it is able to do so, at each step trying to move down, then down-left, then down-right. If all three possible destinations are blocked, the unit of sand **comes to rest** and no longer moves, at which point the next unit of sand is created back at the source.

 So, drawing sand that has come to rest as `o`, the first unit of sand simply falls straight down and then stops:

 ```
 ......+...
 ..........
 ..........
 ..........
 ....#...##
 ....#...#.
 ..###...#.
 ........#.
 ......o.#.
 #########.
 ```

 The second unit of sand then falls straight down, lands on the first one, and then comes to rest to its left:

 ```
 ......+...
 ..........
 ..........
 ..........
 ....#...##
 ....#...#.
 ..###...#.
 ........#.
 .....oo.#.
 #########.
 ```

 After a total of five units of sand have come to rest, they form this pattern:

 ```
 ......+...
 ..........
 ..........
 ..........
 ....#...##
 ....#...#.
 ..###...#.
 ......o.#.
 ....oooo#.
 #########.
 ```

 After a total of 22 units of sand:

 ```
 ......+...
 ..........
 ......o...
 .....ooo..
 ....#ooo##
 ....#ooo#.
 ..###ooo#.
 ....oooo#.
 ...ooooo#.
 #########.
 ```

 Finally, only two more units of sand can possibly come to rest:

 ```
 ......+...
 ..........
 ......o...
 .....ooo..
 ....#ooo##
 ...o#ooo#.
 ..###ooo#.
 ....oooo#.
 .o.ooooo#.
 #########.
 ```

 Once all **`24`** units of sand shown above have come to rest, all further sand flows out the bottom, falling into the endless void. Just for fun, the path any new sand takes before falling forever is shown here with `~`:

 ```
 .......+...
 .......~...
 ......~o...
 .....~ooo..
 ....~#ooo##
 ...~o#ooo#.
 ..~###ooo#.
 ..~..oooo#.
 .~o.ooooo#.
 ~#########.
 ~..........
 ~..........
 ~..........
 ```

 Using your scan, simulate the falling sand. **How many units of sand come to rest before sand starts flowing into the abyss below?**
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
    /// Following the previous path is meant to reduce the number of comparisons calculated for each
    /// consecutive drop.
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

 You realize you misread the scan. There isn't an endless void at the bottom of the scan - there's floor, and you're standing on it!

 You don't have time to scan the floor, so assume the floor is an infinite horizontal line with a `y` coordinate equal to **two plus the highest `y` coordinate** of any point in your scan.

 In the example above, the highest `y` coordinate of any point is `9`, and so the floor is at `y=11`. (This is as if your scan contained one extra rock path like `-infinity,11 -> infinity,11`.) With the added floor, the example above now looks like this:

 ```
         ...........+........
         ....................
         ....................
         ....................
         .........#...##.....
         .........#...#......
         .......###...#......
         .............#......
         .............#......
         .....#########......
         ....................
 <-- etc #################### etc -->
 ```

 To find somewhere safe to stand, you'll need to simulate falling sand until a unit of sand comes to rest at `500,0`, blocking the source entirely and stopping the flow of sand into the cave. In the example above, the situation finally looks like this after **`93`** units of sand come to rest:

 ```
 ............o............
 ...........ooo...........
 ..........ooooo..........
 .........ooooooo.........
 ........oo#ooo##o........
 .......ooo#ooo#ooo.......
 ......oo###ooo#oooo......
 .....oooo.oooo#ooooo.....
 ....oooooooooo#oooooo....
 ...ooo#########ooooooo...
 ..ooooo.......ooooooooo..
 #########################
 ```

 Using your scan, simulate the falling sand until the source of the sand becomes blocked. **How many units of sand come to rest?**
 */

cave.fillCave(from: sandDropPoint, floor: maxY + 2)

print("""
Part 2 Solution:
    Total Sand Units: \(cave.sand.count)
""")

//: [Next](@next)
