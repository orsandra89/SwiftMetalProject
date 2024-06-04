import Foundation
import Metal
import MetalKit

class ConcreteStrategyB: Strategy {
    
    func runGeneticAlgorithm(population: Population, numberOfThreads: Int, generations: Int, items: [Itemm], knapsackCapacity: Int, mutationRate: Float) -> Individual {
        
        let populationCount = population.populationSize / numberOfThreads
        
//        let shaderFileURL = URL(fileURLWithPath: "/Users/eugeniisenyush/VisualStudioProjects/Swift_Metal_Project/Sources/Swift_Metal_Project/Shaders/genetic_algorithm.metal")
//        print(Bundle.module.bundlePath)
        
        let shaderFileURL = Bundle.module.url(
          forResource: "genetic_algorithm",
          withExtension: "metal"
        )
        
        let shaderSource = try! String(contentsOf: shaderFileURL!, encoding: .utf8)
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
//        print(device.maxThreadgroupMemoryLength)
    
        // for s in 0..<population.count {
    
        //     print("Solution \(s): \(population[s]); Total value: \(fitness(solution: population[s]))")
        // }
            
    
        let library = try! device.makeLibrary(source: shaderSource, options: nil)
    
        let functionName = "geneticAlgorithm"
        let kernelFunction = library.makeFunction(name: functionName)!
    
        let commandQueue = device.makeCommandQueue()
        let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
//        print(pipelineState.maxTotalThreadsPerThreadgroup)

        let populationArray = Converter.shared.flattenPopulation(population)
        let itemArray = Converter.shared.convertItemsToIntegers(items)
            //генерація буфорів
        let populationBuffer = device.makeBuffer(bytes: Converter.shared.convertToInt32Array(populationArray), length: numberOfThreads * populationCount * items.count * MemoryLayout<Int32>.stride, options: [])!
        let newPopulationBuffer = device.makeBuffer(length: numberOfThreads * populationCount * items.count * MemoryLayout<Int32>.stride, options: [])!
        let populationSizeBuffer = device.makeBuffer(bytes: [Int32(populationCount)], length: MemoryLayout<Int32>.stride, options: [])!
        let generationsBuffer = device.makeBuffer(bytes: [Int32(generations)], length: MemoryLayout<Int32>.stride, options: [])!
        let itemsBuffer = device.makeBuffer(bytes: Converter.shared.convertToInt32Array(itemArray), length: items.count * 2 * MemoryLayout<Int32>.stride, options: [])!
        let itemsCountBuffer = device.makeBuffer(bytes: [Int32(items.count)], length: MemoryLayout<Int32>.stride, options: [])!
        let knapsackCapacityBuffer = device.makeBuffer(bytes: [Int32(knapsackCapacity)], length: MemoryLayout<Int32>.stride, options: [])!
        let maxSolutionSizeBuffer = device.makeBuffer(bytes: [Int32(items.count)], length: MemoryLayout<Int32>.stride, options: [])!
        let mutationRateBuffer = device.makeBuffer(bytes: [mutationRate], length: MemoryLayout<Float>.stride, options: [])!
    
        let bestSolutionBuffer = device.makeBuffer(length: numberOfThreads * items.count * MemoryLayout<Int32>.stride, options: [])!
        let fitnessScoresBuffer = device.makeBuffer(length: MemoryLayout<Int32>.stride * numberOfThreads * populationCount, options: [])!
    
        let childBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride * items.count, options: [])!
        let mutatedChildBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride * items.count, options: [])!
        let seedBuffer = device.makeBuffer(bytes: [arc4random_uniform(uint32.max)], length: MemoryLayout<uint>.stride, options: [])!
    
        let threadsBuffer = device.makeBuffer(length: numberOfThreads * MemoryLayout<Int32>.stride, options: [])!
    //вставляння буфорів
        let commandBuffer = commandQueue!.makeCommandBuffer()!
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(pipelineState)
        computeEncoder.setBuffer(populationBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(populationSizeBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(generationsBuffer, offset: 0, index: 2)
        computeEncoder.setBuffer(fitnessScoresBuffer, offset: 0, index: 3)
        computeEncoder.setBuffer(bestSolutionBuffer, offset: 0, index: 4)
        computeEncoder.setBuffer(itemsBuffer, offset: 0, index: 5)
        computeEncoder.setBuffer(itemsCountBuffer, offset: 0, index: 6)
        computeEncoder.setBuffer(knapsackCapacityBuffer, offset: 0, index: 7)
        computeEncoder.setBuffer(maxSolutionSizeBuffer, offset: 0, index: 8)
        computeEncoder.setBuffer(mutationRateBuffer, offset: 0, index: 9)
        computeEncoder.setBuffer(newPopulationBuffer, offset: 0, index: 10)
        computeEncoder.setBuffer(childBuffer, offset: 0, index: 11)
        computeEncoder.setBuffer(mutatedChildBuffer, offset: 0, index: 12)
        computeEncoder.setBuffer(seedBuffer, offset: 0, index: 13)
        computeEncoder.setBuffer(threadsBuffer, offset: 0, index: 14)
    
        let threadsPerThreadgroup = MTLSize(width: numberOfThreads, height: 1, depth: 1) // Adjust as needed
        let threadgroupsPerGrid = MTLSize(width: 1, height: 1, depth: 1)
        computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    
        computeEncoder.endEncoding()
        commandBuffer.commit()
    
        commandBuffer.waitUntilCompleted()
    
        let outputBufferContents = bestSolutionBuffer.contents().assumingMemoryBound(to: Int32.self)
        let outputArray = Array(UnsafeBufferPointer(start: outputBufferContents, count: Int(numberOfThreads * items.count)))
        // let outputBufferContents = bestSolutionBuffer.contents().assumingMemoryBound(to: Int.self)
        // let bestSolutionPointer = bestSolutionBuffer.contents().bindMemory(to: Int.self, capacity: 1)
    
//        let fitnessBufferContents = threadsBuffer.contents().assumingMemoryBound(to: Int32.self)
//        let fitnessoutputArray = Array(UnsafeBufferPointer(start: fitnessBufferContents, count: Int(numberOfThreads)))
//    
//        print("fittness: \(fitnessoutputArray)")
    
        var subArrays: [[Int32]] = []
    
        for i in stride(from: 0, to: outputArray.count, by: items.count) {
            let endIndex = min(i + items.count, outputArray.count)
            let subArray = Array(outputArray[i..<endIndex])
            subArrays.append(subArray)
        }
    
        return Population(individuals: subArrays.map { arr in Individual(values: arr.map { $0 != 0 }) }).findBestCandidate(items: items, weightLimit: knapsackCapacity)
    }
        // обрахунок щоби знати скільки даних іде в метал
    func doAlgorithm(p: Population, items: [Itemm], generations: Int, knapsackCapacity: Int, numberOfThreads:Int) -> (Individual, Double ) {
        
        
        let staticsize = items.count * 2 * MemoryLayout<Int32>.stride +
        numberOfThreads * MemoryLayout<Int32>.stride +
        numberOfThreads * MemoryLayout<Int32>.stride * items.count * 3 +
        MemoryLayout<Float>.stride +
        5 * MemoryLayout<Int32>.stride +
        MemoryLayout<uint>.stride
        
        let remainingsize = 32768 - staticsize
        
        let x = remainingsize / (2 * items.count * MemoryLayout<Int32>.stride + MemoryLayout<Int32>.stride * numberOfThreads)
        
        let populationSize = findLargestDivisibleBy10(for: x)
        
        let populations = splitList(p.individuals, intoPartsOf: populationSize).map{ individuals in Population(individuals: individuals) }
        
        let mutationRate: Float = 0.1
        
        var individuals: [Individual] = []
        let startTime = DispatchTime.now()
        
        for pp in populations {
            let individual = runGeneticAlgorithm(population: pp, numberOfThreads: numberOfThreads, generations: generations, items: items, knapsackCapacity: knapsackCapacity, mutationRate: mutationRate)
            individuals.append(individual)
            
        }
        let endTime = DispatchTime.now()
        
        let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        // Return the best solution
        return (Population(individuals: individuals).findBestCandidate(items: items, weightLimit: knapsackCapacity), elapsedTime)
    }
    
    func findLargestDivisibleBy10(for x: Int) -> Int {
        // Perform integer division to find the largest multiple of 100 less than or equal to x
        let largestMultiple = (x / 10) * 10
        return largestMultiple == 0 ? 10 : largestMultiple
    }
    
    func splitList(_ list: [Individual], intoPartsOf size: Int) -> [[Individual]] {
        var result: [[Individual]] = []
        
        // Iterate over the list in steps of size
        for startIndex in stride(from: 0, to: list.count, by: size) {
            let endIndex = min(startIndex + size, list.count) // Calculate the end index for the current portion
            let portion = Array(list[startIndex..<endIndex]) // Extract the portion of the list
            result.append(portion) // Add the portion to the result
        }
        
        return result
    }
}
