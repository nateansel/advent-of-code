/*:
 [Previous](@previous)

 # Day 15: Chiton

 ## Part One

 You've almost reached the exit of the cave, but the walls are getting closer together. Your submarine can barely still fit, though; the main problem is that the walls of the cave are covered in [chitons](https://en.wikipedia.org/wiki/Chiton), and it would be best not to bump any of them.

 The cavern is large, but has a very low ceiling, restricting your motion to two dimensions. The shape of the cavern resembles a square; a quick scan of chiton density produces a map of **risk level** throughout the cave (your puzzle input). For example:

 ```
 1163751742
 1381373672
 2136511328
 3694931569
 7463417111
 1319128137
 1359912421
 3125421639
 1293138521
 2311944581
 ```

 You start in the top left position, your destination is the bottom right position, and you cannot move diagonally. The number at each position is its **risk level**; to determine the total risk of an entire path, add up the risk levels of each position you enter (that is, don't count the risk level of your starting position unless you **enter** it; leaving it adds no risk to your total).

 Your goal is to find a path with the lowest total risk. In this example, a path with the **lowest total risk** is highlighted here:

 ```
 [1] 1  6  3  7  5  1  7  4  2
 [1] 3  8  1  3  7  3  6  7  2
 [2][1][3][6][5][1][1] 3  2  8
  3  6  9  4  9  3 [1][5] 6  9
  7  4  6  3  4  1  7 [1] 1  1
  1  3  1  9  1  2  8 [1][3] 7
  1  3  5  9  9  1  2  4 [2] 1
  3  1  2  5  4  2  1  6 [3] 9
  1  2  9  3  1  3  8  5 [2][1]
  2  3  1  1  9  4  4  5  8 [1]
 ```

 The total risk of this path is **`40`** (the starting position is never entered, so its risk is not counted).

 **What is the lowest total risk of any path from the top left to the bottom right?**
 */

import Foundation

guard let input = FileImport.getInput() else { fatalError("Input Not Retrieved") }

let smallGraph = Graph(rawValue: input)
let smallDistance = smallGraph.shortestPath()

print("""
Part 1 Solution:
    Lowest Risk Level: \(smallDistance)
""")

/*:
 ## Part Two

 Now that you know how to find low-risk paths in the cave, you can try to find your way out.

 The entire cave is actually **five times larger in both dimensions** than you thought; the area you originally scanned is just one tile in a 5x5 tile area that forms the full map. Your original map tile repeats to the right and downward; each time the tile repeats to the right or downward, all of its risk levels **are 1 higher** than the tile immediately up or left of it. However, risk levels above 9 wrap back around to 1. So, if your original map had some position with a risk level of 8, then that same position on each of the 25 total tiles would be as follows:

 ```
 8 9 1 2 3
 9 1 2 3 4
 1 2 3 4 5
 2 3 4 5 6
 3 4 5 6 7
 ```

 Each single digit above corresponds to the example position with a value of 8 on the top-left tile. Because the full map is actually five times larger in both dimensions, that position appears a total of 25 times, once in each duplicated tile, with the values shown above.

 Here is the full five-times-as-large version of the first example above, with the original map in the top left corner highlighted:

 ```
 1163751742 2274862853338597396444961841755517295286
 1381373672 2492484783351359589446246169155735727126
 2136511328 3247622439435873354154698446526571955763
 3694931569 4715142671582625378269373648937148475914
 7463417111 8574528222968563933317967414442817852555
 1319128137 2421239248353234135946434524615754563572
 1359912421 2461123532357223464346833457545794456865
 3125421639 4236532741534764385264587549637569865174
 1293138521 2314249632342535174345364628545647573965
 2311944581 3422155692453326671356443778246755488935

 2274862853 3385973964449618417555172952866628316397
 2492484783 3513595894462461691557357271266846838237
 3247622439 4358733541546984465265719557637682166874
 4715142671 5826253782693736489371484759148259586125
 8574528222 9685639333179674144428178525553928963666
 2421239248 3532341359464345246157545635726865674683
 2461123532 3572234643468334575457944568656815567976
 4236532741 5347643852645875496375698651748671976285
 2314249632 3425351743453646285456475739656758684176
 3422155692 4533266713564437782467554889357866599146
 3385973964 4496184175551729528666283163977739427418
 3513595894 4624616915573572712668468382377957949348
 4358733541 5469844652657195576376821668748793277985
 5826253782 6937364893714847591482595861259361697236
 9685639333 1796741444281785255539289636664139174777
 3532341359 4643452461575456357268656746837976785794
 3572234643 4683345754579445686568155679767926678187
 5347643852 6458754963756986517486719762859782187396
 3425351743 4536462854564757396567586841767869795287
 4533266713 5644377824675548893578665991468977611257
 4496184175 5517295286662831639777394274188841538529
 4624616915 5735727126684683823779579493488168151459
 5469844652 6571955763768216687487932779859814388196
 6937364893 7148475914825958612593616972361472718347
 1796741444 2817852555392896366641391747775241285888
 4643452461 5754563572686567468379767857948187896815
 4683345754 5794456865681556797679266781878137789298
 6458754963 7569865174867197628597821873961893298417
 4536462854 5647573965675868417678697952878971816398
 5644377824 6755488935786659914689776112579188722368
 5517295286 6628316397773942741888415385299952649631
 5735727126 6846838237795794934881681514599279262561
 6571955763 7682166874879327798598143881961925499217
 7148475914 8259586125936169723614727183472583829458
 2817852555 3928963666413917477752412858886352396999
 5754563572 6865674683797678579481878968159298917926
 5794456865 6815567976792667818781377892989248891319
 7569865174 8671976285978218739618932984172914319528
 5647573965 6758684176786979528789718163989182927419
 6755488935 7866599146897761125791887223681299833479
 ```

 Equipped with the full map, you can now find a path from the top left corner to the bottom right corner with the lowest total risk:

 [1] 1  6  3  7  5  1  7  4  2  2  2  7  4  8  6  2  8  5  3  3  3  8  5  9  7  3  9  6  4  4  4  9  6  1  8  4  1  7  5  5  5  1  7  2  9  5  2  8  6
 [1] 3  8  1  3  7  3  6  7  2  2  4  9  2  4  8  4  7  8  3  3  5  1  3  5  9  5  8  9  4  4  6  2  4  6  1  6  9  1  5  5  7  3  5  7  2  7  1  2  6
 [2] 1  3  6  5  1  1  3  2  8  3  2  4  7  6  2  2  4  3  9  4  3  5  8  7  3  3  5  4  1  5  4  6  9  8  4  4  6  5  2  6  5  7  1  9  5  5  7  6  3
 [3] 6  9  4  9  3  1  5  6  9  4  7  1  5  1  4  2  6  7  1  5  8  2  6  2  5  3  7  8  2  6  9  3  7  3  6  4  8  9  3  7  1  4  8  4  7  5  9  1  4
 [7] 4  6  3  4  1  7  1  1  1  8  5  7  4  5  2  8  2  2  2  9  6  8  5  6  3  9  3  3  3  1  7  9  6  7  4  1  4  4  4  2  8  1  7  8  5  2  5  5  5
 [1] 3  1  9  1  2  8  1  3  7  2  4  2  1  2  3  9  2  4  8  3  5  3  2  3  4  1  3  5  9  4  6  4  3  4  5  2  4  6  1  5  7  5  4  5  6  3  5  7  2
 [1] 3  5  9  9  1  2  4  2  1  2  4  6  1  1  2  3  5  3  2  3  5  7  2  2  3  4  6  4  3  4  6  8  3  3  4  5  7  5  4  5  7  9  4  4  5  6  8  6  5
 [3] 1  2  5  4  2  1  6  3  9  4  2  3  6  5  3  2  7  4  1  5  3  4  7  6  4  3  8  5  2  6  4  5  8  7  5  4  9  6  3  7  5  6  9  8  6  5  1  7  4
 [1] 2  9  3  1  3  8  5  2  1  2  3  1  4  2  4  9  6  3  2  3  4  2  5  3  5  1  7  4  3  4  5  3  6  4  6  2  8  5  4  5  6  4  7  5  7  3  9  6  5
 [2] 3  1  1  9  4  4  5  8  1  3  4  2  2  1  5  5  6  9  2  4  5  3  3  2  6  6  7  1  3  5  6  4  4  3  7  7  8  2  4  6  7  5  5  4  8  8  9  3  5
 [2] 2  7  4  8  6  2  8  5  3  3  3  8  5  9  7  3  9  6  4  4  4  9  6  1  8  4  1  7  5  5  5  1  7  2  9  5  2  8  6  6  6  2  8  3  1  6  3  9  7
 [2] 4  9  2  4  8  4  7  8  3  3  5  1  3  5  9  5  8  9  4  4  6  2  4  6  1  6  9  1  5  5  7  3  5  7  2  7  1  2  6  6  8  4  6  8  3  8  2  3  7
 [3][2][4] 7  6  2  2  4  3  9  4  3  5  8  7  3  3  5  4  1  5  4  6  9  8  4  4  6  5  2  6  5  7  1  9  5  5  7  6  3  7  6  8  2  1  6  6  8  7  4
  4  7 [1][5] 1  4  2  6  7  1  5  8  2  6  2  5  3  7  8  2  6  9  3  7  3  6  4  8  9  3  7  1  4  8  4  7  5  9  1  4  8  2  5  9  5  8  6  1  2  5
  8  5  7 [4] 5  2  8  2  2  2  9  6  8  5  6  3  9  3  3  3  1  7  9  6  7  4  1  4  4  4  2  8  1  7  8  5  2  5  5  5  3  9  2  8  9  6  3  6  6  6
  2  4  2 [1] 2  3  9  2  4  8  3  5  3  2  3  4  1  3  5  9  4  6  4  3  4  5  2  4  6  1  5  7  5  4  5  6  3  5  7  2  6  8  6  5  6  7  4  6  8  3
  2  4  6 [1][1][2][3][5][3][2] 3  5  7  2  2  3  4  6  4  3  4  6  8  3  3  4  5  7  5  4  5  7  9  4  4  5  6  8  6  5  6  8  1  5  5  6  7  9  7  6
  4  2  3  6  5  3  2  7  4 [1] 5  3  4  7  6  4  3  8  5  2  6  4  5  8  7  5  4  9  6  3  7  5  6  9  8  6  5  1  7  4  8  6  7  1  9  7  6  2  8  5
  2  3  1  4  2  4  9  6  3 [2][3][4][2] 5  3  5  1  7  4  3  4  5  3  6  4  6  2  8  5  4  5  6  4  7  5  7  3  9  6  5  6  7  5  8  6  8  4  1  7  6
  3  4  2  2  1  5  5  6  9  2  4  5 [3][3][2] 6  6  7  1  3  5  6  4  4  3  7  7  8  2  4  6  7  5  5  4  8  8  9  3  5  7  8  6  6  5  9  9  1  4  6
  3  3  8  5  9  7  3  9  6  4  4  4  9  6 [1] 8  4  1  7  5  5  5  1  7  2  9  5  2  8  6  6  6  2  8  3  1  6  3  9  7  7  7  3  9  4  2  7  4  1  8
  3  5  1  3  5  9  5  8  9  4  4  6  2  4 [6][1] 6  9  1  5  5  7  3  5  7  2  7  1  2  6  6  8  4  6  8  3  8  2  3  7  7  9  5  7  9  4  9  3  4  8
  4  3  5  8  7  3  3  5  4  1  5  4  6  9  8 [4][4] 6  5  2  6  5  7  1  9  5  5  7  6  3  7  6  8  2  1  6  6  8  7  4  8  7  9  3  2  7  7  9  8  5
  5  8  2  6  2  5  3  7  8  2  6  9  3  7  3  6 [4] 8  9  3  7  1  4  8  4  7  5  9  1  4  8  2  5  9  5  8  6  1  2  5  9  3  6  1  6  9  7  2  3  6
  9  6  8  5  6  3  9  3  3  3  1  7  9  6  7  4 [1] 4  4  4  2  8  1  7  8  5  2  5  5  5  3  9  2  8  9  6  3  6  6  6  4  1  3  9  1  7  4  7  7  7
  3  5  3  2  3  4  1  3  5  9  4  6  4  3  4  5 [2][4][6][1] 5  7  5  4  5  6  3  5  7  2  6  8  6  5  6  7  4  6  8  3  7  9  7  6  7  8  5  7  9  4
  3  5  7  2  2  3  4  6  4  3  4  6  8  3  3  4  5  7  5 [4] 5  7  9  4  4  5  6  8  6  5  6  8  1  5  5  6  7  9  7  6  7  9  2  6  6  7  8  1  8  7
  5  3  4  7  6  4  3  8  5  2  6  4  5  8  7  5  4  9  6 [3] 7  5  6  9  8  6  5  1  7  4  8  6  7  1  9  7  6  2  8  5  9  7  8  2  1  8  7  3  9  6
  3  4  2  5  3  5  1  7  4  3  4  5  3  6  4  6  2  8  5 [4][5][6][4] 7  5  7  3  9  6  5  6  7  5  8  6  8  4  1  7  6  7  8  6  9  7  9  5  2  8  7
  4  5  3  3  2  6  6  7  1  3  5  6  4  4  3  7  7  8  2  4  6  7 [5][5][4] 8  8  9  3  5  7  8  6  6  5  9  9  1  4  6  8  9  7  7  6  1  1  2  5  7
  4  4  9  6  1  8  4  1  7  5  5  5  1  7  2  9  5  2  8  6  6  6  2  8 [3][1][6][3] 9  7  7  7  3  9  4  2  7  4  1  8  8  8  4  1  5  3  8  5  2  9
  4  6  2  4  6  1  6  9  1  5  5  7  3  5  7  2  7  1  2  6  6  8  4  6  8  3  8 [2] 3  7  7  9  5  7  9  4  9  3  4  8  8  1  6  8  1  5  1  4  5  9
  5  4  6  9  8  4  4  6  5  2  6  5  7  1  9  5  5  7  6  3  7  6  8  2  1  6  6 [8] 7  4  8  7  9  3  2  7  7  9  8  5  9  8  1  4  3  8  8  1  9  6
  6  9  3  7  3  6  4  8  9  3  7  1  4  8  4  7  5  9  1  4  8  2  5  9  5  8  6 [1][2][5] 9  3  6  1  6  9  7  2  3  6  1  4  7  2  7  1  8  3  4  7
  1  7  9  6  7  4  1  4  4  4  2  8  1  7  8  5  2  5  5  5  3  9  2  8  9  6  3  6  6 [6][4][1][3] 9  1  7  4  7  7  7  5  2  4  1  2  8  5  8  8  8
  4  6  4  3  4  5  2  4  6  1  5  7  5  4  5  6  3  5  7  2  6  8  6  5  6  7  4  6  8  3  7  9 [7] 6  7  8  5  7  9  4  8  1  8  7  8  9  6  8  1  5
  4  6  8  3  3  4  5  7  5  4  5  7  9  4  4  5  6  8  6  5  6  8  1  5  5  6  7  9  7  6  7  9 [2][6] 6  7  8  1  8  7  8  1  3  7  7  8  9  2  9  8
  6  4  5  8  7  5  4  9  6  3  7  5  6  9  8  6  5  1  7  4  8  6  7  1  9  7  6  2  8  5  9  7  8 [2][1] 8  7  3  9  6  1  8  9  3  2  9  8  4  1  7
  4  5  3  6  4  6  2  8  5  4  5  6  4  7  5  7  3  9  6  5  6  7  5  8  6  8  4  1  7  6  7  8  6  9 [7] 9  5  2  8  7  8  9  7  1  8  1  6  3  9  8
  5  6  4  4  3  7  7  8  2  4  6  7  5  5  4  8  8  9  3  5  7  8  6  6  5  9  9  1  4  6  8  9  7  7 [6][1][1][2] 5  7  9  1  8  8  7  2  2  3  6  8
  5  5  1  7  2  9  5  2  8  6  6  6  2  8  3  1  6  3  9  7  7  7  3  9  4  2  7  4  1  8  8  8  4  1  5  3  8 [5] 2  9  9  9  5  2  6  4  9  6  3  1
  5  7  3  5  7  2  7  1  2  6  6  8  4  6  8  3  8  2  3  7  7  9  5  7  9  4  9  3  4  8  8  1  6  8  1  5  1 [4] 5  9  9  2  7  9  2  6  2  5  6  1
  6  5  7  1  9  5  5  7  6  3  7  6  8  2  1  6  6  8  7  4  8  7  9  3  2  7  7  9  8  5  9  8  1  4  3  8  8 [1] 9  6  1  9  2  5  4  9  9  2  1  7
  7  1  4  8  4  7  5  9  1  4  8  2  5  9  5  8  6  1  2  5  9  3  6  1  6  9  7  2  3  6  1  4  7  2  7  1  8 [3][4][7][2][5] 8  3  8  2  9  4  5  8
  2  8  1  7  8  5  2  5  5  5  3  9  2  8  9  6  3  6  6  6  4  1  3  9  1  7  4  7  7  7  5  2  4  1  2  8  5  8  8  8  6 [3] 5  2  3  9  6  9  9  9
  5  7  5  4  5  6  3  5  7  2  6  8  6  5  6  7  4  6  8  3  7  9  7  6  7  8  5  7  9  4  8  1  8  7  8  9  6  8  1  5  9 [2] 9  8  9  1  7  9  2  6
  5  7  9  4  4  5  6  8  6  5  6  8  1  5  5  6  7  9  7  6  7  9  2  6  6  7  8  1  8  7  8  1  3  7  7  8  9  2  9  8  9 [2][4] 8  8  9  1  3  1  9
  7  5  6  9  8  6  5  1  7  4  8  6  7  1  9  7  6  2  8  5  9  7  8  2  1  8  7  3  9  6  1  8  9  3  2  9  8  4  1  7  2  9 [1][4][3][1] 9  5  2  8
  5  6  4  7  5  7  3  9  6  5  6  7  5  8  6  8  4  1  7  6  7  8  6  9  7  9  5  2  8  7  8  9  7  1  8  1  6  3  9  8  9  1  8  2  9 [2] 7  4  1  9
  6  7  5  5  4  8  8  9  3  5  7  8  6  6  5  9  9  1  4  6  8  9  7  7  6  1  1  2  5  7  9  1  8  8  7  2  2  3  6  8  1  2  9  9  8 [3][3][4][7][9]
 ```

 The total risk of this path is **`315`** (the starting position is still never entered, so its risk is not counted).

 Using the full map, **what is the lowest total risk of any path from the top left to the bottom right?**
 */

let largeGraph = Graph(rawValue: input, multiple: 5)
let largeDistance = largeGraph.shortestPath()

print("""
Part 2 Solution:
    Lowest Risk Level: \(largeDistance)
""")

//: [Next](@next)
