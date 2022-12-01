import Foundation

public struct Point: Equatable, Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    var above: Point { Point(x: x - 1, y: y) }
    var below: Point { Point(x: x + 1, y: y) }
    var left: Point { Point(x: x, y: y - 1) }
    var right: Point { Point(x: x, y: y + 1) }
    var edges: [Point] { [above, below, left, right] }
}

extension Array where Element == [Int] {
    subscript(_ point: Point) -> Int {
        get { self[point.x][point.y] }
        set { self[point.x][point.y] = newValue }
    }
}

public class Graph {
    public var values: [[Int]]

    public init(values: [[Int]]) {
        guard !values.isEmpty, values.allSatisfy({ $0.count == values[0].count })
        else {
            fatalError("This graph is not a valid grid.")
        }
        self.values = values
    }

    public convenience init(rawValue: String, multiple: Int = 1) {
        let values = rawValue
            .components(separatedBy: .newlines)
            .map {
                $0.compactMap({ Int("\($0)") })
            }

        guard !values.isEmpty, values.allSatisfy({ $0.count == values[0].count })
        else {
            fatalError("This graph is not a valid grid.")
        }

        let rowCount = values.count
        let columnCount = values[0].count
        var fullGrid: [[Int]] = Array(
            repeating: Array(
                repeating: 0,
                count: columnCount * multiple
            ),
            count: rowCount * multiple
        )

        for row in fullGrid.indices {
            let rowFactor = row / rowCount
            for column in fullGrid[0].indices {
                let columnFactor = column / columnCount
                var value = values[row % rowCount][column % columnCount]
                let factor = rowFactor + columnFactor
                value += factor
                if value > 9 {
                    value -= 9
                }
                fullGrid[row][column] = value
            }
        }

        self.init(values: fullGrid)
    }

    public func shortestPath() -> Int {
        shortestPath(
            from: Point(x: 0, y: 0),
            to: Point(x: values.count - 1, y: values[0].count - 1)
        )
    }

    public func shortestPath(from start: Point, to end: Point) -> Int {
        var toVisit: Set = [start]
        var currentPoint = start
        var distances = [start: 0]

        while !toVisit.isEmpty {
            toVisit.remove(currentPoint)
            for point in currentPoint.edges.filter({ isPointValid($0) }) {
                let distance = distances[currentPoint]! + values[point]
                if distance < distances[point, default: .max] {
                    distances[point] = distance
                    toVisit.insert(point)
                }
            }
            if let nextPoint = toVisit.min(by: { distances[$0, default: .max] < distances[$1, default: .max] }) {
                currentPoint = nextPoint
            }
            if currentPoint == end {
                return distances[end, default: -1]
            }
        }

        return -1
    }

    func isPointValid(_ point: Point) -> Bool {
        point.x >= 0
            && point.x < values.count
            && point.y >= 0
            && point.y < values[0].count
    }
}
