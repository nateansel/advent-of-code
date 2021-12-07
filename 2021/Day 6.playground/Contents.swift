import Foundation

let input = {
    """
    4,3,4,5,2,1,1,5,5,3,3,1,5,1,4,2,2,3,1,5,1,4,1,2,3,4,1,4,1,5,2,1,1,3,3,5,1,1,1,1,4,5,1,2,1,2,1,1,1,5,3,3,1,1,1,1,2,4,2,1,2,3,2,5,3,5,3,1,5,4,5,4,4,4,1,1,2,1,3,1,1,4,2,1,2,1,2,5,4,2,4,2,2,4,2,2,5,1,2,1,2,1,4,4,4,3,2,1,2,4,3,5,1,1,3,4,2,3,3,5,3,1,4,1,1,1,1,2,3,2,1,1,5,5,1,5,2,1,4,4,4,3,2,2,1,2,1,5,1,4,4,1,1,4,1,4,2,4,3,1,4,1,4,2,1,5,1,1,1,3,2,4,1,1,4,1,4,3,1,5,3,3,3,4,1,1,3,1,3,4,1,4,5,1,4,1,2,2,1,3,3,5,3,2,5,1,1,5,1,5,1,4,4,3,1,5,5,2,2,4,1,1,2,1,2,1,4,3,5,5,2,3,4,1,4,2,4,4,1,4,1,1,4,2,4,1,2,1,1,1,1,1,1,3,1,3,3,1,1,1,1,3,2,3,5,4,2,4,3,1,5,3,1,1,1,2,1,4,4,5,1,5,1,1,1,2,2,4,1,4,5,2,4,5,2,2,2,5,4,4
    """
}()

func calculateLanternFishSpawn(`for` initialFish: [Int], totalDays: Int, daysForFirstSpawn: Int = 9, daysForSubsequentSpawns: Int = 7) -> Int {
    let indexForSubsequentSpawns = daysForSubsequentSpawns - 1

    // Initialize fish spawns
    var fishAtSpawnRates: [Int] = Array(repeating: 0, count: daysForFirstSpawn)
    initialFish.forEach { fishAtSpawnRates[$0] += 1 }

    // Advance the next day's fish
    for _ in 0..<totalDays {
        let spawningFish = fishAtSpawnRates.remove(at: 0)
        fishAtSpawnRates.append(spawningFish)
        fishAtSpawnRates[indexForSubsequentSpawns] += spawningFish
    }

    return fishAtSpawnRates.reduce(0, +)
}

let fish = input.components(separatedBy: ",").compactMap({ Int($0) })
let lanternFishPopulationAt80 = calculateLanternFishSpawn(for: fish, totalDays: 80)

print("""
Puzzle 1 Solution:
    Lantern fish population after 80 days: \(lanternFishPopulationAt80)
""")

// MARK: Puzzle 2

let lanternFishPopulationAt256 = calculateLanternFishSpawn(for: fish, totalDays: 256)
print("""
Puzzle 2 Solution:
    Lantern fish population after 256 days: \(lanternFishPopulationAt256)
""")
