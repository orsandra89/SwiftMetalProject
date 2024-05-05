import Foundation
import Metal
import MetalKit

let shaderFileURL = URL(fileURLWithPath: "/Users/eugeniisenyush/VisualStudioProjects/Swift_Metal_Project/Shaders/find_max_number_in_list.metal")
let shaderSource = try String(contentsOf: shaderFileURL, encoding: .utf8)

// Define the number of lists
let numberOfLists = 5

// Generate n lists of integers
var lists = [[Int]]()
for _ in 0..<numberOfLists {
    let list = (0..<10).map { _ in Int.random(in: 0..<100) } // Generate a list of 10 random integers
    lists.append(list)
}

// Function to find the maximum element in a list using Metal
func findMaxElementUsingMetal(list: [Int]) -> Int {
    // Set up Metal
    guard let device = MTLCreateSystemDefaultDevice() else {
        fatalError("Metal is not supported on this device.")
    }

    let library = try! device.makeLibrary(source: shaderSource, options: nil)
    
    let functionName = "findMax" 
    let kernelFunction = library.makeFunction(name: functionName)!

    let commandQueue = device.makeCommandQueue()
    let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
    
    // Prepare input and output buffers
    let inputBuffer = device.makeBuffer(bytes: list, length: list.count * MemoryLayout<Int>.stride, options: [])!
    let outputBuffer = device.makeBuffer(length: MemoryLayout<Int>.stride, options: [])!
    
    // Set up compute command encoder
    let commandBuffer = commandQueue!.makeCommandBuffer()!
    let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
    computeCommandEncoder.setComputePipelineState(pipelineState)
    computeCommandEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
    computeCommandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
    
    // Dispatch the kernel
    let gridSize = MTLSize(width: 1, height: 1, depth: 1)
    let threadgroupSize = MTLSize(width: 1, height: 1, depth: 1)
    computeCommandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
    computeCommandEncoder.endEncoding()
    
    // Execute the command buffer
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    
    // Extract result from the output buffer
    let maxElement = UnsafeMutablePointer<Int>(OpaquePointer(outputBuffer.contents())).pointee
    return maxElement
    // return list.max()!
}

// Find max element from each list using Metal
var maxElements = [Int]()
// let maxElements = list[numberOfLists]
for _ in 1...numberOfLists {
    let list = (0..<10).map { _ in Int.random(in: 0..<100) }
    let maxElement = findMaxElementUsingMetal(list: list)
    print("Max number: \(maxElement)")
    maxElements.append(maxElement)
}

// Print the maximum number from each list
print("Max elements from each list:")
for (index, maxElement) in maxElements.enumerated() {
    print("List \(index + 1): \(maxElement)")
}
