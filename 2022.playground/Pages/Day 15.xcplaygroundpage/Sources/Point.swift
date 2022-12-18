import Foundation

public struct Point: CustomStringConvertible, Equatable, Hashable {
    public let x: Int
    public let y: Int

    public var description: String { "(\(x), \(y))" }

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public init(rawValue: String) {
        let components = rawValue.split(separator: ", ")
        x = Int(components[0].split(separator: "=")[1])!
        y = Int(components[1].split(separator: "=")[1])!
    }
}
