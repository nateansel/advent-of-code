import Foundation

public extension Array where Element == ClosedRange<Int> {
   func combined() -> [ClosedRange<Int>] {
       var ranges = sorted(by: <)
       var combinedRanges = [ranges.removeFirst()]
       while !ranges.isEmpty {
           let range = ranges.removeFirst()
           if combinedRanges.last!.contains(range.lowerBound) {
               let combinedRange = combinedRanges.removeLast()
               combinedRanges.append(combinedRange.lowerBound...Swift.max(combinedRange.upperBound, range.upperBound))
           } else {
               combinedRanges.append(range)
           }
       }
       return combinedRanges
   }
}

public extension Array where Element == Sensor {
    func combinedXRanges(for y: Int) -> [ClosedRange<Int>] {
        compactMap({ $0.xRange(for: y) }).combined()
    }
}
