/*:
 [Previous](@previous)

 # Day 4: Giant Squid

 ## Part One

 You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you **can** see, however, is a giant squid that has attached itself to the outside of your submarine.

 Maybe it wants to play [bingo](https://en.wikipedia.org/wiki/Bingo_(American_version))?

 Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is **marked** on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board **wins**. (Diagonals don't count.)

 The submarine has a **bingo subsystem** to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

 ```
 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

 22 13 17 11  0
  8  2 23  4 24
 21  9 14 16  7
  6 10  3 18  5
  1 12 20 15 19

  3 15  0  2 22
  9 18 13 17  5
 19  8  7 25 23
 20 11 10 24  4
 14 21 16 12  6

 14 21 17 24  4
 10 16 15  9 19
 18  8 23 26 20
 22 11 13  6  5
  2  0 12  3  7
 ```

 After the first five numbers are drawn (`7`, `4`, `9`, `5`, and `11`), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

 ```
 22  13  17 [11]   0        3   15   0   2 22        14  21  17 24  [4]
  8   2  23  [4]  24       [9]  18  13  17 [5]       10  16  15 [9] 19
 21  [9] 14  16   [7]      19    8  [7] 25 23        18   8  23 26  20
  6  10   3  18   [5]      20  [11] 10  24 [4]       22 [11] 13  6  [5]
  1  12  20  15   19       14   21  16  12  6         2   0  12  3  [7]
 ```

 After the next six numbers are drawn (`17`, `23`, `2`, `0`, `14`, and `21`), there are still no winners:

 ```
  22  13  [17] [11] [0]        3   15  [0]  [2]  22         [14] [21] [17] 24  [4]
   8  [2] [23] [4]  24        [9]  18  13  [17]  [5]         10   16   15  [9] 19
 [21] [9] [14] 16   [7]       19    8  [7]  25  [23]         18    8  [23] 26  20
   6  10    3  18   [5]       20  [11] 10   24   [4]         22  [11]  13   6  [5]
   1  12   20  15   19       [14] [21] 16   12    6          [2]  [0]  12   3  [7]
 ```

 Finally, `24` is drawn:

 ```
  22  13  [17] [11]  [0]        3   15  [0]  [2]  22         [14] [21] [17] [24] [4]
   8  [2] [23] [4]  [24]       [9]  18  13  [17]  [5]         10   16   15   [9] 19
 [21] [9] [14] 16    [7]       19    8  [7]  25  [23]         18    8  [23]  26  20
   6  10    3  18    [5]       20  [11] 10  [24]  [4]         22  [11]  13    6  [5]
   1  12   20  15    19       [14] [21] 16   12    6          [2]  [0]  12    3  [7]
 ```

 At this point, the third board **wins** because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: **`14 21 17 24 4`**).

 The **score** of the winning board can now be calculated. Start by finding the **sum of all unmarked numbers** on that board; in this case, the sum is `188`. Then, multiply that sum by the **number that was just called** when the board won, `24`, to get the final score, `188 * 24 = 4512`.

 To guarantee victory against the giant squid, figure out which board will win first. **What will your final score be if you choose that board?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

struct Number {
    let value: Int
    var marked: Bool = false
}

struct Board {
    /// The rows that make up this board.
    var rows: [[Number]]

    /// A flag indicating if at least one row or column is entirely marked.
    var isMarked: Bool {
        for index in rows.indices {
            if isRowMarked(at: index) {
                return true
            }
        }
        for index in rows.first?.indices ?? 0..<0 {
            if isColumnMarked(at: index) {
                return true
            }
        }
        return false
    }

    var unmarkedNumbers: [Number] {
        rows
            .flatMap { $0 }
            .filter { !$0.marked }
    }

    init?(rawValue: String) {
        let numbers = rawValue
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { $0.components(separatedBy: .whitespaces) }
            .map { $0.compactMap({ Int($0) }) }
        guard numbers.count == 5 && numbers.allSatisfy({ $0.count == 5 }) else { return nil }
        self.rows = numbers.map { $0.map({ Number(value: $0) }) }
    }

    private func isRowMarked(at index: Int) -> Bool {
        guard rows.indices.contains(index) else { return false }
        return rows[index].allSatisfy { $0.marked }
    }

    private func isColumnMarked(at index: Int) -> Bool {
        guard rows.allSatisfy({ $0.indices.contains(index) }) else { return false }
        return rows.allSatisfy { $0[index].marked }
    }

    /// Marks any value in this board that matches the given number.
    mutating func mark(_ number: Int) {
        for row in rows.indices {
            for column in rows[row].indices {
                if rows[row][column].value == number {
                    rows[row][column].marked = true
                }
            }
        }
    }
}

func parse(input: String) -> (numbers: [Int], boards: [Board]) {
    let lines = input.components(separatedBy: .newlines)
    let numbers = lines.first?.components(separatedBy: ",").compactMap({ Int($0) })
    let rawBoardLines = lines
        .dropFirst()
        .filter { !$0.isEmpty }
    let boards = stride(from: 0, to: rawBoardLines.count, by: 5)
        .map { rawBoardLines[$0..<min($0 + 5, rawBoardLines.count)].joined(separator: "\n") }
        .compactMap { Board(rawValue: $0) }
    return (numbers: numbers ?? [], boards: boards)
}

func playToWin(with numbers: [Int], boards: [Board]) -> (winningNumber: Int, winningBoard: Board)? {
    var boards = boards
    for number in numbers {
        for index in boards.indices {
            boards[index].mark(number)
            if boards[index].isMarked {
                return (winningNumber: number, winningBoard: boards[index])
            }
        }
    }
    return nil
}

let (numbers, boards) = parse(input: input)
guard let (winningNumber, winningBoard) = playToWin(with: numbers, boards: boards) else { fatalError() }
let unmarkedNumbers = winningBoard.unmarkedNumbers.map { $0.value }
let unmarkedSum = unmarkedNumbers.reduce(0, +)

print("""
Part 1 Solution (if you want to win):
    Winning Number: \(winningNumber)
    Unmarked Numbers: \(unmarkedNumbers)
    Unmarked Sum: \(unmarkedSum)
    Answer: \(unmarkedSum * winningNumber)
""")

/*:
 ## Part Two

 On the other hand, it might be wise to try a different strategy: let the giant squid win.

 You aren't sure how many bingo boards a giant squid could play at once, so rather than waste time counting its arms, the safe thing to do is to **figure out which board will win last** and choose that one. That way, no matter which boards it picks, it will win for sure.

 In the above example, the second board is the last to win, which happens after `13` is eventually called and its middle column is completely marked. If you were to keep playing until this point, the second board would have a sum of unmarked numbers equal to `148` for a final score of `148 * 13 = 1924`.

 Figure out which board will win last. **Once it wins, what would its final score be?**
 */

func playToLose(with numbers: [Int], boards: [Board]) -> (losingNumber: Int, losingBoard: Board)? {
    var boards = boards
    for number in numbers {
        var boardsToRemove: [Int] = []
        for index in boards.indices {
            boards[index].mark(number)
            if boards[index].isMarked {
                if boards.count == 1 {
                    return (losingNumber: number, losingBoard: boards[index])
                }
                boardsToRemove.append(index)
            }
        }
        for index in boardsToRemove.reversed() {
            boards.remove(at: index)
        }
    }
    return nil
}

guard let (losingNumber, losingBoard) = playToLose(with: numbers, boards: boards) else { fatalError() }
let losingUnmarkedNumbers = losingBoard.unmarkedNumbers.map { $0.value }
let losingUnmarkedSum = losingUnmarkedNumbers.reduce(0, +)

print("""
Part 2 Solution (if you want to lose):
    Losing Number: \(losingNumber)
    Unmarked Numbers: \(losingUnmarkedNumbers)
    Unmarked Sum: \(losingUnmarkedSum)
    Answer: \(losingUnmarkedSum * losingNumber)
""")

//: [Next](@next)
