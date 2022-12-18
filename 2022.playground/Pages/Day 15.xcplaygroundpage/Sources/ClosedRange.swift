import Foundation

public extension ClosedRange {
   func fullyContains(_ other: ClosedRange<Bound>) -> Bool {
       contains(other.lowerBound) && contains(other.upperBound)
   }

   func combined(with other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
       guard contains(other.lowerBound) else { return nil }
       return lowerBound...Swift.max(upperBound, other.upperBound)
   }
}

extension ClosedRange: Comparable where Bound: Comparable, Bound: Equatable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
       if lhs.lowerBound == rhs.lowerBound {
           return lhs.upperBound < rhs.upperBound
       }
       return lhs.lowerBound < rhs.lowerBound
   }
}
