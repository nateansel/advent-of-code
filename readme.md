# 🎄 Advent of Code 🎄

[Advent of Code](https://adventofcode.com/2022) is a Christmas themed programming problem set that is released as an advent calendar every year.

The advent calendar runs each year from December 1st through the 25th, with each day’s puzzle progressing in difficulty, culminating in Christmas’s puzzle being the most difficult to solve.

This repository contains my own solutions for these puzzles, with each year being separated into its own Swift Playground. These playground files can be opened in Xcode or in Swift Playgrounds.

## Playground File Structure

Each year is contained in its own playground, with each day’s puzzles being separated into their own pages within the playground.

### Puzzle Input

Puzzle input is placed in `txt` documents in the `Resources` directory for each page.

#### `FileImport` Helper

Since each puzzle relies on importing a large amount of puzzle input to run calculations on, each playground contains a global helper (`FileImport`) for importing the input as a String.

Any additional playground helpers that are used by every day’s puzzle are also placed in the global `Sources` directory in that playground.

### Additional Code in `Sources` Directory

If any day’s puzzle does not contain all of the code for a solution, make sure to look in that day’s `Sources` directory. If a particular puzzle takes an exorbitant amount of time to compute, even after optimizations are put in place, I will move the expensive code into an external source file. This greatly speeds up computation time since Playgrounds doesn’t log each of the lines of code that is run in those source files. And less logging means faster computation.