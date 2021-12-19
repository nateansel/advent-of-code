/*:
 [Previous](@previous)

 # Day 12: Passage Pathing ---

 With your submarine's subterranean subsystems subsisting suboptimally, the only way you're getting out of this cave anytime soon is by finding a path yourself. Not just a path - the only way to know if you've found the best path is to find all of them.

 Fortunately, the sensors are still mostly working, and so you build a rough map of the remaining caves (your puzzle input). For example:

 start-A
 start-b
 A-c
 A-b
 b-d
 A-end
 b-end
 This is a list of how all of the caves are connected. You start in the cave named start, and your destination is the cave named end. An entry like b-d means that cave b is connected to cave d - that is, you can move between them.

 So, the above cave system looks roughly like this:

     start
     /   \
 c--A-----b--d
     \   /
      end
 Your goal is to find the number of distinct paths that start at start, end at end, and don't visit small caves more than once. There are two types of caves: big caves (written in uppercase, like A) and small caves (written in lowercase, like b). It would be a waste of time to visit any small cave more than once, but big caves are large enough that it might be worth visiting them multiple times. So, all paths you find should visit small caves at most once, and can visit big caves any number of times.

 Given these rules, there are 10 paths through this example cave system:

 start,A,b,A,c,A,end
 start,A,b,A,end
 start,A,b,end
 start,A,c,A,b,A,end
 start,A,c,A,b,end
 start,A,c,A,end
 start,A,end
 start,b,A,c,A,end
 start,b,A,end
 start,b,end
 (Each line in the above list corresponds to a single path; the caves visited by that path are listed in the order they are visited and separated by commas.)

 Note that in this cave system, cave d is never visited by any path: to do so, cave b would need to be visited twice (once on the way to cave d and a second time when returning from cave d), and since cave b is small, this is not allowed.

 Here is a slightly larger example:

 dc-end
 HN-start
 start-kj
 dc-start
 dc-HN
 LN-dc
 HN-end
 kj-sa
 kj-HN
 kj-dc
 The 19 paths through it are as follows:

 start,HN,dc,HN,end
 start,HN,dc,HN,kj,HN,end
 start,HN,dc,end
 start,HN,dc,kj,HN,end
 start,HN,end
 start,HN,kj,HN,dc,HN,end
 start,HN,kj,HN,dc,end
 start,HN,kj,HN,end
 start,HN,kj,dc,HN,end
 start,HN,kj,dc,end
 start,dc,HN,end
 start,dc,HN,kj,HN,end
 start,dc,end
 start,dc,kj,HN,end
 start,kj,HN,dc,HN,end
 start,kj,HN,dc,end
 start,kj,HN,end
 start,kj,dc,HN,end
 start,kj,dc,end
 Finally, this even larger example has 226 paths through it:

 fs-end
 he-DX
 fs-he
 start-DX
 pj-DX
 end-zg
 zg-sl
 zg-pj
 pj-he
 RW-he
 fs-DX
 pj-RW
 zg-RW
 start-pj
 he-WI
 zg-he
 pj-fs
 start-RW
 How many paths through this cave system are there that visit small caves at most once?
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

class Cave: CustomDebugStringConvertible, Equatable {
    enum Size: String {
        case big, small
    }

    let id: String
    let size: Size
    var connections: [Cave]

    init(id: String, size: Size, connections: [Cave]) {
        self.id = id
        self.size = size
        self.connections = connections
    }

    init(rawValue: String) {
        id = rawValue
        size = rawValue.allSatisfy({ $0.isLowercase }) ? .small : .big
        connections = []
    }

    var debugDescription: String {
        """
        Cave:
            id: \(id)
            size: \(size)
            connections: \(connections.map({ $0.id }))
        """
    }

    static func ==(lhs: Cave, rhs: Cave) -> Bool {
        lhs.id == rhs.id
    }
}

class Path: CustomDebugStringConvertible {
    var caves: [Cave]

    init(caves: [Cave] = []) {
        self.caves = caves
    }

    var copy: Path { Path(caves: caves) }

    var debugDescription: String {
        caves.map({ $0.id }).joined(separator: ",")
    }
}

class CaveGraph {
    let start: Cave
    let end: Cave

    init(start: Cave, end: Cave) {
        self.start = start
        self.end = end
    }

    init(rawValue: String) {
        let rawConnections = rawValue
            .components(separatedBy: .newlines)
            .map { $0.components(separatedBy: "-") }
        let caves = Set(rawConnections.flatMap({ $0 }))
            .map { Cave(rawValue: $0) }

        let connections = rawConnections
            .map { ($0.first!, $0.last!) }
        for cave in caves {
            for connection in connections {
                if cave.id == connection.0 {
                    for other in caves.filter({ $0.id == connection.1 }) {
                        cave.connections.append(other)
                    }
                } else if cave.id == connection.1 {
                    for other in caves.filter({ $0.id == connection.0 }) {
                        cave.connections.append(other)
                    }
                }
            }
        }

        start = caves.first(where: { $0.id == "start" })!
        end = caves.first(where: { $0.id == "end" })!
    }

    func findAllPaths(allowingDuplicateSmallCaves: Bool = false) -> [Path] {
        findAllPaths(from: start, canVisitSmallTwice: allowingDuplicateSmallCaves)
    }

    private func findAllPaths(from cave: Cave, currentPath: Path = Path(), canVisitSmallTwice: Bool = false) -> [Path] {
        currentPath.caves.append(cave)

        // If at the end of the cave system, return the current set of paths
        guard cave != end else { return [currentPath] }

        var paths: [Path] = []
        for connection in cave.connections {
            let visitCount = currentPath.caves.filter({ $0 == connection }).count
            let canUseConnection = connection != start
                && (connection.size == .big
                    || (!canVisitSmallTwice && visitCount == 0)
                    || (canVisitSmallTwice && visitCount < 2)
                )
            if canUseConnection {
                var newCanVisitSmallTwice = canVisitSmallTwice
                if canVisitSmallTwice {
                    if connection.size == .big {
                        newCanVisitSmallTwice = canVisitSmallTwice
                    } else {
                        newCanVisitSmallTwice = visitCount == 0
                    }
                }
                paths.append(contentsOf: findAllPaths(
                    from: connection,
                    currentPath: currentPath.copy,
                    canVisitSmallTwice: newCanVisitSmallTwice))
            }
        }
        return paths
    }
}

let graph = CaveGraph(rawValue: input)
//let smallPaths = graph.findAllPaths()
//
//print("""
//Part 1 Solution:
//    Total paths: \(smallPaths.count)
//""")

/*:
 ## Part Two
 After reviewing the available paths, you realize you might have time to visit a single small cave **twice**. Specifically, big caves can be visited any number of times, a single small cave can be visited at most twice, and the remaining small caves can be visited at most once. However, the caves named `start` and `end` can only be visited exactly once each: once you leave the `start` cave, you may not return to it, and once you reach the `end` cave, the path must end immediately.

 Now, the `36` possible paths through the first example above are:

 ```
 start,A,b,A,b,A,c,A,end
 start,A,b,A,b,A,end
 start,A,b,A,b,end
 start,A,b,A,c,A,b,A,end
 start,A,b,A,c,A,b,end
 start,A,b,A,c,A,c,A,end
 start,A,b,A,c,A,end
 start,A,b,A,end
 start,A,b,d,b,A,c,A,end
 start,A,b,d,b,A,end
 start,A,b,d,b,end
 start,A,b,end
 start,A,c,A,b,A,b,A,end
 start,A,c,A,b,A,b,end
 start,A,c,A,b,A,c,A,end
 start,A,c,A,b,A,end
 start,A,c,A,b,d,b,A,end
 start,A,c,A,b,d,b,end
 start,A,c,A,b,end
 start,A,c,A,c,A,b,A,end
 start,A,c,A,c,A,b,end
 start,A,c,A,c,A,end
 start,A,c,A,end
 start,A,end
 start,b,A,b,A,c,A,end
 start,b,A,b,A,end
 start,b,A,b,end
 start,b,A,c,A,b,A,end
 start,b,A,c,A,b,end
 start,b,A,c,A,c,A,end
 start,b,A,c,A,end
 start,b,A,end
 start,b,d,b,A,c,A,end
 start,b,d,b,A,end
 start,b,d,b,end
 start,b,end
 ```

 The slightly larger example above now has `103` paths through it, and the even larger example now has `3509` paths through it.

 Given these new rules, **how many paths through this cave system are there?**
 */

extension CaveGraph{
    func countAllPaths(allowingDuplicateSmallCaves: Bool = false) -> Int {
        countAllPaths(from: start, canVisitSmallTwice: allowingDuplicateSmallCaves)
    }

    private func countAllPaths(from cave: Cave, visitCount: [String: Int] = [:], canVisitSmallTwice: Bool = false) -> Int {
        var visitCount = visitCount
        visitCount[cave.id, default: 0] += 1

        // If at the end of the cave system, return 1, which is the count of this path.
        guard cave != end else { return 1 }

        var count = 0
        for connection in cave.connections {
            let connectionVisitCount = visitCount[connection.id, default: 0]
            let canUseConnection = connection != start
                && (connection.size == .big
                    || (!canVisitSmallTwice && connectionVisitCount == 0)
                    || (canVisitSmallTwice && connectionVisitCount < 2)
                )
            if canUseConnection {
                var newCanVisitSmallTwice = canVisitSmallTwice
                if canVisitSmallTwice {
                    if connection.size == .big {
                        newCanVisitSmallTwice = canVisitSmallTwice
                    } else {
                        newCanVisitSmallTwice = connectionVisitCount == 0
                    }
                }
                count += countAllPaths(
                    from: connection,
                    visitCount: visitCount,
                    canVisitSmallTwice: newCanVisitSmallTwice)
            }
        }
        return count
    }

let twicePathsCount = graph.countAllPaths(allowingDuplicateSmallCaves: true)
print("""
Part 2 Solution:
    Total paths: \(twicePathsCount)
""")

//: [Next](@next)
