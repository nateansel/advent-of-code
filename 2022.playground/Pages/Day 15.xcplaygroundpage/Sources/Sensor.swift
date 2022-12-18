import Foundation

public struct Sensor: Equatable, Hashable {
    public let point: Point
    public let beacon: Point

    public init(rawValue: String) {
        let components = rawValue.split(separator: ": ")
        point = Point(rawValue: String(components[0].trimmingPrefix("Sensor at ")))
        beacon = Point(rawValue: String(components[1].trimmingPrefix("closest beacon is at ")))
    }

    public func xRange(for y: Int) -> ClosedRange<Int>? {
        let maxDelta = abs(point.x - beacon.x) + abs(point.y - beacon.y)
        guard ((point.y - maxDelta)...(point.y + maxDelta)).contains(y) else { return nil }
        let xDelta = abs(maxDelta - abs(y - point.y))
        return (point.x - xDelta)...(point.x + xDelta)
    }
}
