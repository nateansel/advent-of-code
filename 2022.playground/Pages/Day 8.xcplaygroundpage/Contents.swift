/*:
 [Previous](@previous)

 # Day 8: Treetop Tree House

 ## Part One

 The expedition comes across a peculiar patch of tall trees all planted carefully in a grid. The Elves explain that a previous expedition planted these trees as a reforestation effort. Now, they're curious if this would be a good location for a [tree house](https://en.wikipedia.org/wiki/Tree_house).

 First, determine whether there is enough tree cover here to keep a tree house **hidden**. To do this, you need to count the number of trees that are **visible from outside the grid** when looking directly along a row or column.

 The Elves have already launched a [quadcopter](https://en.wikipedia.org/wiki/Quadcopter) to generate a map with the height of each tree (your puzzle input). For example:

 ```
 30373
 25512
 65332
 33549
 35390
 ```

 Each tree is represented as a single digit whose value is its height, where `0` is the shortest and `9` is the tallest.

 A tree is **visible** if all of the other trees between it and an edge of the grid are **shorter** than it. Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.

 All of the trees around the edge of the grid are visible - since they are already on the edge, there are no trees to block the view. In this example, that only leaves the **interior nine trees** to consider:

 - The top-left `5` is **visible** from the left and top. (It isn't visible from the right or bottom since other trees of height 5 are in the way.)
 - The top-middle `5` is **visible** from the top and right.
 - The top-right `1` is not visible from any direction; for it to be visible, there would need to only be trees of height 0 between it and an edge.
 - The left-middle `5` is **visible**, but only from the right.
 - The center `3` is not visible from any direction; for it to be visible, there would need to be only trees of at most height `2` between it and an edge.
 - The right-middle `3` is **visible** from the right.
 - In the bottom row, the middle `5` is **visible*, but the `3` and `4` are not.

 With 16 trees visible on the edge and another 5 visible in the interior, a total of **`21`** trees are visible in this arrangement.

 Consider your map; **how many trees are visible from outside the grid?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

class Grove {
    let trees: [[Int]]
    let rowIndices: Range<Int>
    let columnIndices: Range<Int>

    init(rawValue: String) {
        trees = rawValue
            .components(separatedBy: .newlines)
            .map {
                $0.compactMap { Int("\($0)") }
            }
        rowIndices = trees.indices
        columnIndices = trees[0].indices
    }

    func calculateVisibility() -> [[Bool]] {
        var visibility = Array(
            repeating: Array(
                repeating: false,
                count: columnIndices.count
            ),
            count: rowIndices.count
        )
        for row in rowIndices {
            if row == 0 || row == rowIndices.last {
                for column in columnIndices {
                    visibility[row][column] = true
                }
                continue
            }
            for column in columnIndices {
                if column == 0 || column == columnIndices.last {
                    visibility[row][column] = true
                    continue
                }
                visibility[row][column] = calculateTreeVisibility(row: row, column: column)
            }
        }
        return visibility
    }

    func calculateTreeVisibility(row: Int, column: Int) -> Bool {
        let tree = trees[row][column]
        let leftPoints = columnIndices[0..<column]
        let rightPoints = columnIndices[(column + 1)...]
        let upPoints = rowIndices[0..<row]
        let downPoints = rowIndices[(row + 1)...]

        return leftPoints.allSatisfy({ trees[row][$0] < tree })
            || rightPoints.allSatisfy({ trees[row][$0] < tree })
            || upPoints.allSatisfy({ trees[$0][column] < tree })
            || downPoints.allSatisfy({ trees[$0][column] < tree })
    }
}

let grove = Grove(rawValue: input)
let visibility = grove.calculateVisibility()
let visibleTrees = visibility.reduce(0, { $0 + $1.reduce(0, { $0 + ($1 ? 1 : 0) }) })

print("""
Part 1 Solution:
    Total Visible Trees: \(visibleTrees)
""")

/*:
 ## Part Two

 Content with the amount of tree cover available, the Elves just need to know the best spot to build their tree house: they would like to be able to see a lot of **trees**.

 To measure the viewing distance from a given tree, look up, down, left, and right from that tree; stop if you reach an edge or at the first tree that is the same height or taller than the tree under consideration. (If a tree is right on the edge, at least one of its viewing distances will be zero.)

 The Elves don't care about distant trees taller than those found by the rules above; the proposed tree house has large [eaves](https://en.wikipedia.org/wiki/Eaves) to keep it dry, so they wouldn't be able to see higher than the tree house anyway.

 In the example above, consider the middle `5` in the second row:

 ```
 30373
 25512
 65332
 33549
 35390
 ```

 - Looking up, its view is not blocked; it can see **`1`** tree (of height `3`).
 - Looking left, its view is blocked immediately; it can see only **`1`** tree (of height `5`, right next to it).
 - Looking right, its view is not blocked; it can see **`2`** trees.
 - Looking down, its view is blocked eventually; it can see **`2`** trees (one of height `3`, then the tree of height `5` that blocks its view).

 A tree's **scenic score** is found by **multiplying together** its viewing distance in each of the four directions. For this tree, this is **`4`** (found by multiplying `1 * 1 * 2 * 2`).

 However, you can do even better: consider the tree of height `5` in the middle of the fourth row:

 ```
 30373
 25512
 65332
 33549
 35390
 ```

 - Looking up, its view is blocked at **`2`** trees (by another tree with a height of `5`).
 - Looking left, its view is not blocked; it can see **`2`** trees.
 - Looking down, its view is also not blocked; it can see **`1`** tree.
 - Looking right, its view is blocked at **`2`** trees (by a massive tree of height `9`).

 This tree's scenic score is **`8`** (`2 * 2 * 1 * 2`); this is the ideal spot for the tree house.

 Consider each tree on your map. **What is the highest scenic score possible for any tree?**
 */

extension Grove {
    func calculateScenicScores() -> [[Int]] {
        var scenicScores = Array(
            repeating: Array(
                repeating: 0,
                count: columnIndices.count
            ),
            count: rowIndices.count
        )
        for row in rowIndices {
            for column in columnIndices {
                let viewingDistance = calculateViewingDistance(row: row, column: column)
                let scenicScore = viewingDistance.up
                    * viewingDistance.down
                    * viewingDistance.left
                    * viewingDistance.right
                scenicScores[row][column] = scenicScore
            }
        }
        return scenicScores
    }

    func calculateViewingDistance(row: Int, column: Int) -> (up: Int, down: Int, left: Int, right: Int) {
        let tree = trees[row][column]
        let leftPoints = Array(columnIndices[0..<column].reversed())
        let rightPoints = Array(columnIndices[(column + 1)...])
        let upPoints = Array(rowIndices[0..<row].reversed())
        let downPoints = Array(rowIndices[(row + 1)...])

        var viewingDistance = (up: 0, down: 0, left: 0, right: 0)
        for (index, column) in leftPoints.enumerated() {
            if trees[row][column] >= tree {
                viewingDistance.left = index + 1
                break
            }
            if index == leftPoints.indices.last {
                viewingDistance.left = index + 1
            }
        }
        for (index, column) in rightPoints.enumerated() {
            if trees[row][column] >= tree {
                viewingDistance.right = index + 1
                break
            }
            if index == rightPoints.indices.last {
                viewingDistance.right = index + 1
            }
        }
        for (index, row) in upPoints.enumerated() {
            if trees[row][column] >= tree {
                viewingDistance.up = index + 1
                break
            }
            if index == upPoints.indices.last {
                viewingDistance.up = index + 1
            }
        }
        for (index, row) in downPoints.enumerated() {
            if trees[row][column] >= tree {
                viewingDistance.down = index + 1
                break
            }
            if index == downPoints.indices.last {
                viewingDistance.down = index + 1
            }
        }

        return viewingDistance
    }
}

let scenicScores = grove.calculateScenicScores()
let mostScenicTree = scenicScores
    .flatMap { $0 }
    .max()!

print("""
Part 2 Solution:
    Most Scenic Tree Score: \(mostScenicTree)
""")

//: [Next](@next)
