//import Foundation
//import Metal
//import MetalKit
//
//let shaderFileURL = URL(fileURLWithPath: "/Users/eugeniisenyush/VisualStudioProjects/Swift_Metal_Project/Shaders/genetic_algorithm.metal")
//let shaderSource = try String(contentsOf: shaderFileURL, encoding: .utf8)
//
//// Define an item struct representing items in the knapsack
//struct Item {
//    let weight: Int
//    let value: Int
//}
//
//struct Solution {
//    var values: [Bool]
//}
//
//func convertToInt32Array(_ arr : [Int]) -> [Int32] {
//    return arr.map { Int32($0) }
//}
//
//func flattenSolutions(_ solutions: [Solution]) -> [Int] {
//    // Convert [Solution] to [[Int]]
//    let arrayOfArrays = solutions.map { solution in
//        solution.values.map { $0 ? Int(1) : Int(0) }
//    }
//    
//    // Flatten [[Int]] into [Int]
//    let flattenedArray = arrayOfArrays.flatMap { $0 }
//    
//    return flattenedArray
//}
//
//func convertItemsToIntegers(_ items: [Item]) -> [Int] {
//    return items.flatMap { [ $0.weight, $0.value ] }
//}
//
//// Genetic Algorithm parameters
//let populationSize = Int(1000)
//let generations = Int(1000)
//let mutationRate: Float = 0.1
//
//// Knapsack parameters
//let knapsackCapacity = Int(50)
//let items = [
//    Item(weight: Int(10), value: Int(60)),
//    Item(weight: Int(20), value: Int(100)),
//    Item(weight: Int(30), value: Int(120))
//]
//
//// Function to generate a random solution
//func generateRandomSolution() -> Solution {
//    let values = (0..<items.count).map { _ in Bool.random() }
//    return Solution(values: values)
//}
//
//// Function to calculate the fitness of a solution
//func fitness(solution: Solution) -> Int {
//    let totalWeight = solution.values.enumerated().reduce(0) { (total, tuple) in
//        total + (tuple.element ? items[tuple.offset].weight : 0)
//    }
//    let totalValue = solution.values.enumerated().reduce(0) { (total, tuple) in
//        total + (tuple.element ? items[tuple.offset].value : 0)
//    }
//    return totalWeight > knapsackCapacity ? 0 : totalValue
//}
//
//// Function to perform crossover between two solutions
//func crossover(parent1: Solution, parent2: Solution) -> Solution {
//    let crossoverPoint = Int.random(in: Int(0)..<Int(parent1.values.count))
//    let child = parent1.values.prefix(crossoverPoint) + parent2.values.suffix(parent2.values.count - crossoverPoint)
//    return Solution(values: Array(child))
//}
//
//// Function to perform mutation on a solution
//func mutate(solution: Solution) -> Solution {
//    return Solution(values: solution.values.map { bit in
//        if Float.random(in: 0..<1) < mutationRate {
//            return !bit
//        } else {
//            return bit
//        }
//    })
//}
//
//// Main genetic algorithm function
//func geneticAlgorithm(population: [Solution], generations: Int) -> Solution {
//    var population = population
//    
//    for _ in 0..<generations {
//        // Evaluate fitness of each solution
//        let fitnessScores = population.map { solution in
//            return fitness(solution: solution)
//        }
//        
//        // Select parents based on fitness
//        let parent1 = population[Int(fitnessScores.argmax()!)]
//        let parent2 = population[Int(fitnessScores.argmax()!)]
//        
//        // Generate new population through crossover and mutation
//        var newPopulation = [parent1, parent2]
//        while newPopulation.count < populationSize {
//            let child = crossover(parent1: parent1, parent2: parent2)
//            newPopulation.append(mutate(solution: child))
//        }
//        
//        population = newPopulation
//    }
//    
//    // Return the best solution
//    return population.max { solution1, solution2 in
//        return fitness(solution: solution1) < fitness(solution: solution2)
//    }!
//}
//
//// Helper function to find index of maximum element in an array
//extension Array where Element: Comparable {
//    func argmax() -> Int? {
//        guard let maxElement = self.max() else { return nil }
//        return firstIndex(of: maxElement)
//    }
//}
//
//var population: [Solution] = (0..<populationSize).map { _ in generateRandomSolution() }
//
//// Running the genetic algorithm
//let bestSolution = geneticAlgorithm(population: population, generations: generations)
//print("Best solution: \(bestSolution)")
//print("Total value: \(fitness(solution: bestSolution))")
//
//
//// Metal
//
//func geneticAlgorithmMetal(populations: [[Solution]], generations: Int) -> [Solution] {
//    // var allBestSolutions = [Solution]()
//        
//    // for population in populations {
//    //     let bestSolution = runGeneticAlgorithm(population: population, generations: generations, items: items, knapsackCapacity: knapsackCapacity, mutationRate: mutationRate)
//    //     allBestSolutions.append(bestSolution)
//    // }
//    
//    // return allBestSolutions
//    return runGeneticAlgorithm(population: populations, populationCount: populationSize, generations: generations, items: items, knapsackCapacity: knapsackCapacity, mutationRate: mutationRate)
//}
//
//func runGeneticAlgorithm(population: [[Solution]], populationCount: Int, generations: Int, items: [Item], knapsackCapacity: Int, mutationRate: Float) -> [Solution] {
//    guard let device = MTLCreateSystemDefaultDevice() else {
//        fatalError("Metal is not supported on this device.")
//    }
//    print(device.maxThreadgroupMemoryLength)
//
//    let numberOfThreads = population.count
//
//    // for s in 0..<population.count {
//    
//    //     print("Solution \(s): \(population[s]); Total value: \(fitness(solution: population[s]))")
//    // }
//
//    let library = try! device.makeLibrary(source: shaderSource, options: nil)
//    
//    let functionName = "geneticAlgorithm" 
//    let kernelFunction = library.makeFunction(name: functionName)!
//
//    let commandQueue = device.makeCommandQueue()
//    let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
//    print(pipelineState.maxTotalThreadsPerThreadgroup)
//    
//    let flattenPopulation = population.flatMap{ $0 }
//    let populationArray = flattenSolutions(flattenPopulation)
//    let itemArray = convertItemsToIntegers(items)
//
//    let populationBuffer = device.makeBuffer(bytes: convertToInt32Array(populationArray), length: numberOfThreads * populationCount * items.count * MemoryLayout<Int32>.stride, options: [])!
//    let newPopulationBuffer = device.makeBuffer(length: numberOfThreads * populationCount * items.count * MemoryLayout<Int32>.stride, options: [])!
//    let populationSizeBuffer = device.makeBuffer(bytes: [Int32(populationCount)], length: MemoryLayout<Int32>.stride, options: [])!
//    let generationsBuffer = device.makeBuffer(bytes: [Int32(generations)], length: MemoryLayout<Int32>.stride, options: [])!
//    let itemsBuffer = device.makeBuffer(bytes: convertToInt32Array(itemArray), length: items.count * 2 * MemoryLayout<Int32>.stride, options: [])!
//    let itemsCountBuffer = device.makeBuffer(bytes: [Int32(items.count)], length: MemoryLayout<Int32>.stride, options: [])!
//    let knapsackCapacityBuffer = device.makeBuffer(bytes: [Int32(knapsackCapacity)], length: MemoryLayout<Int32>.stride, options: [])!
//    let maxSolutionSizeBuffer = device.makeBuffer(bytes: [Int32(items.count)], length: MemoryLayout<Int32>.stride, options: [])!
//    let mutationRateBuffer = device.makeBuffer(bytes: [mutationRate], length: MemoryLayout<Float>.stride, options: [])!
//    
//    let bestSolutionBuffer = device.makeBuffer(length: numberOfThreads * items.count * MemoryLayout<Int32>.stride, options: [])!
//    let fitnessScoresBuffer = device.makeBuffer(length: MemoryLayout<Int32>.stride * numberOfThreads * populationCount, options: [])!
//
//    let childBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride * items.count, options: [])!
//    let mutatedChildBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride * items.count, options: [])!
//    let seedBuffer = device.makeBuffer(bytes: [arc4random_uniform(uint32.max)], length: MemoryLayout<uint>.stride, options: [])!
//
//    let threadsBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride, options: [])!
//    
//    let commandBuffer = commandQueue!.makeCommandBuffer()!
//    let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
//    computeEncoder.setComputePipelineState(pipelineState)
//    computeEncoder.setBuffer(populationBuffer, offset: 0, index: 0)
//    computeEncoder.setBuffer(populationSizeBuffer, offset: 0, index: 1)
//    computeEncoder.setBuffer(generationsBuffer, offset: 0, index: 2)
//    computeEncoder.setBuffer(fitnessScoresBuffer, offset: 0, index: 3)
//    computeEncoder.setBuffer(bestSolutionBuffer, offset: 0, index: 4)
//    computeEncoder.setBuffer(itemsBuffer, offset: 0, index: 5)
//    computeEncoder.setBuffer(itemsCountBuffer, offset: 0, index: 6)
//    computeEncoder.setBuffer(knapsackCapacityBuffer, offset: 0, index: 7)
//    computeEncoder.setBuffer(maxSolutionSizeBuffer, offset: 0, index: 8)
//    computeEncoder.setBuffer(mutationRateBuffer, offset: 0, index: 9)
//    computeEncoder.setBuffer(newPopulationBuffer, offset: 0, index: 10)
//    computeEncoder.setBuffer(childBuffer, offset: 0, index: 11)
//    computeEncoder.setBuffer(mutatedChildBuffer, offset: 0, index: 12)
//    computeEncoder.setBuffer(seedBuffer, offset: 0, index: 13)
//    computeEncoder.setBuffer(threadsBuffer, offset: 0, index: 14)
//    
//    let threadsPerThreadgroup = MTLSize(width: numberOfThreads, height: 1, depth: 1) // Adjust as needed
//    let threadgroupsPerGrid = MTLSize(width: 1,
//                                  height: 1,
//                                  depth: 1)
//    computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//    
//    computeEncoder.endEncoding()
//    commandBuffer.commit()
//    
//    commandBuffer.waitUntilCompleted()
//    
//    let outputBufferContents = bestSolutionBuffer.contents().assumingMemoryBound(to: Int32.self)
//    let outputArray = Array(UnsafeBufferPointer(start: outputBufferContents, count: Int(numberOfThreads * items.count)))
//    // let outputBufferContents = bestSolutionBuffer.contents().assumingMemoryBound(to: Int.self)
//    // let bestSolutionPointer = bestSolutionBuffer.contents().bindMemory(to: Int.self, capacity: 1)
//
//    let fitnessBufferContents = threadsBuffer.contents().assumingMemoryBound(to: Int32.self)
//    let fitnessoutputArray = Array(UnsafeBufferPointer(start: fitnessBufferContents, count: Int(numberOfThreads)))
//
//    print("fittness: \(fitnessoutputArray)")
//
//    var subArrays: [[Int32]] = []
//
//    for i in stride(from: 0, to: outputArray.count, by: items.count) {
//        let endIndex = min(i + items.count, outputArray.count)
//        let subArray = Array(outputArray[i..<endIndex])
//        subArrays.append(subArray)
//    }
//
//    return subArrays.map { arr in Solution(values: arr.map { $0 != 0 }) }
//}
//
//var populations = [[Solution]]()
//for _ in 0..<10 {
//    let population: [Solution] = (0..<populationSize).map { _ in generateRandomSolution() }
//    populations.append(population)
//}
//
//
//let bestSolutions = geneticAlgorithmMetal(populations: populations, generations: generations)
//for s in 0..<10 {
//    
//    print("Best solution \(s): \(bestSolutions[s]); Total value: \(fitness(solution: bestSolutions[s]))")
//}
