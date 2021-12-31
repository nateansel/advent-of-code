/*:
 [Previous](@previous)

 # Day 13: Transparent Origami

 ## Part One

 You reach another volcanically active part of the cave. It would be nice if you could do some kind of thermal imaging so you could tell ahead of time which caves are too hot to safely enter.

 Fortunately, the submarine seems to be equipped with a thermal camera! When you activate it, you are greeted with:

 `Congratulations on your purchase! To activate this infrared thermal imaging camera system, please enter the code found on page 1 of the manual.`

 Apparently, the Elves have never used this feature. To your surprise, you manage to find the manual; as you go to open it, page 1 falls out. It's a large sheet of [transparent paper](https://en.wikipedia.org/wiki/Transparency_(projection))! The transparent paper is marked with random dots and includes instructions on how to fold it up (your puzzle input). For example:

 ```
 6,10
 0,14
 9,10
 0,3
 10,4
 4,11
 6,0
 6,12
 4,1
 0,13
 10,12
 3,4
 3,0
 8,4
 1,10
 2,14
 8,10
 9,0

 fold along y=7
 fold along x=5
 ```

 The first section is a list of dots on the transparent paper. `0,0` represents the top-left coordinate. The first value, `x`, increases to the right. The second value, `y`, increases downward. So, the coordinate `3,0` is to the right of `0,0`, and the coordinate `0,7` is below `0,0`. The coordinates in this example form the following pattern, where `#` is a dot on the paper and `.` is an empty, unmarked position:

 ```
 ...#..#..#.
 ....#......
 ...........
 #..........
 ...#....#.#
 ...........
 ...........
 ...........
 ...........
 ...........
 .#....#.##.
 ....#......
 ......#...#
 #..........
 #.#........
 ```

 Then, there is a list of **fold instructions**. Each instruction indicates a line on the transparent paper and wants you to fold the paper up (for horizontal y=... lines) or left (for vertical x=... lines). In this example, the first fold instruction is fold along y=7, which designates the line formed by all of the positions where y is 7 (marked here with -):

 ```
 ...#..#..#.
 ....#......
 ...........
 #..........
 ...#....#.#
 ...........
 ...........
 -----------
 ...........
 ...........
 .#....#.##.
 ....#......
 ......#...#
 #..........
 #.#........
 ```

 Because this is a horizontal line, fold the bottom half up. Some of the dots might end up overlapping after the fold is complete, but dots will never appear exactly on a fold line. The result of doing this fold looks like this:

 ```
 #.##..#..#.
 #...#......
 ......#...#
 #...#......
 .#.#..#.###
 ...........
 ...........
 ```

 Now, only 17 dots are visible.

 Notice, for example, the two dots in the bottom left corner before the transparent paper is folded; after the fold is complete, those dots appear in the top left corner (at 0,0 and 0,1). Because the paper is transparent, the dot just below them in the result (at 0,3) remains visible, as it can be seen through the transparent paper.

 Also notice that some dots can end up overlapping; in this case, the dots merge together and become a single dot.

 The second fold instruction is fold along x=5, which indicates this line:

 ```
 #.##.|#..#.
 #...#|.....
 .....|#...#
 #...#|.....
 .#.#.|#.###
 .....|.....
 .....|.....
 ```

 Because this is a vertical line, fold left:

 ```
 #####
 #...#
 #...#
 #...#
 #####
 .....
 .....
 ```

 The instructions made a square!

 The transparent paper is pretty big, so for now, focus on just completing the first fold. After the first fold in the example above, `17` dots are visible - dots that end up overlapping after the fold is completed count as a single dot.

 **How many dots are visible after completing just the first fold instruction on your transparent paper?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

enum Direction {
    case horizontal, vertical
}

struct Instruction: CustomDebugStringConvertible {
    var direction: Direction
    var location: Int

    var debugDescription: String {
        "fold along \(direction == .vertical ? "y" : "x")=\(location)"
    }

    init(direction: Direction, location: Int) {
        self.direction = direction
        self.location = location
    }

    init(rawValue: String) {
        guard let components = rawValue.components(separatedBy: .whitespaces).last?.components(separatedBy: "=")
            else { fatalError() }
        direction = components.first == "y" ? .vertical : .horizontal
        location = Int(components.last ?? "") ?? -1
    }
}

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int
}

struct Paper: CustomDebugStringConvertible {
    var points: Set<Point>

    var debugDescription: String {
        createGrid()
            .map { $0.map({ $0 ? "#" : "." }).joined() }
            .joined(separator: "\n")
    }

    private func createGrid() -> [[Bool]] {
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? 0
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? 0

        var grid = Array(repeating: Array(repeating: false, count: maxX + 1), count: maxY + 1)
        for point in points {
            grid[point.y][point.x] = true
        }

        return grid
    }

    func fold(with instruction: Instruction) -> Paper {
        switch instruction.direction {
        case .vertical: return foldVertically(at: instruction.location)
        case .horizontal: return foldHorizontally(at: instruction.location)
        }
    }

    private func foldVertically(at index: Int) -> Paper {
        var newPoints: Set<Point> = points.filter { $0.y < index }
        let pointsToAdjust = points.subtracting(newPoints)

        for point in pointsToAdjust {
            let adjustedPoint = Point(
                x: point.x,
                y: index - (point.y - index))
            newPoints.insert(adjustedPoint)
        }
        return Paper(points: newPoints)
    }

    private func foldHorizontally(at index: Int) -> Paper {
        var newPoints: Set<Point> = points.filter { $0.x < index }
        let pointsToAdjust = points.subtracting(newPoints)

        for point in pointsToAdjust {
            let adjustedPoint = Point(
                x: index - (point.x - index),
                y: point.y)
            newPoints.insert(adjustedPoint)
        }
        return Paper(points: newPoints)
    }
}

func parse(input: String) -> (paper: Paper, folds: [Instruction]) {
    var folds: [Instruction] = []
    var points: Set<Point> = []
    for line in input.components(separatedBy: .newlines) {
        if line.isEmpty {
            continue
        } else if line.starts(with: "fold along") {
            folds.append(Instruction(rawValue: line))
        } else {
            let values = line.components(separatedBy: ",").compactMap({ Int($0) })
            if values.count == 2 {
                points.insert(Point(x: values[0], y: values[1]))
            }
        }
    }
    return (paper: Paper(points: points), folds: folds)
}

let (paper, folds) = parse(input: input)
let afterFirstFold = paper.fold(with: folds[0])

print("""
Part 1 Solution:
    After first fold: \(afterFirstFold.points.count) dots
""")

/*:
 ## Part Two

 Finish folding the transparent paper according to the instructions. The manual says the code is always eight capital letters.

 **What code do you use to activate the infrared thermal imaging camera system?**
 */

extension Paper {
    func fold(all instructions: [Instruction]) -> Paper {
        var currentPaper = self
        for instruction in instructions {
            currentPaper = currentPaper.fold(with: instruction)
        }
        return currentPaper
    }
}

let finalPaper = paper.fold(all: folds)

print("""
Part 2 Solution:
    Final Paper: \(finalPaper.points.count) dots
    \(finalPaper.debugDescription.components(separatedBy: .newlines).joined(separator: "\n    "))
""")

//: [Next](@next)
