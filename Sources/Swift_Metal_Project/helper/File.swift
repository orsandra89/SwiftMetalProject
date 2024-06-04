//
//  File.swift
//  
//
//  Created by Eugenii Senyush on 05/05/2024.
//

import Foundation

struct Record {
    let algorithm: String
    let populationSize: Int
    let itemsSize: Int
    let calculationTime: Double
    let numberOfThreads: Int
}

class Converter {

    /// The static field that controls the access to the singleton instance.
    ///
    /// This implementation let you extend the Singleton class while keeping
    /// just one instance of each subclass around.
    static var shared: Converter = {
        let instance = Converter()
        return instance
    }()

    /// The Singleton's initializer should always be private to prevent direct
    /// construction calls with the `new` operator.
    private init() {}

    /// Finally, any singleton should define some business logic, which can be
    /// executed on its instance.
    func convertItemsToIntegers(_ items: [Itemm]) -> [Int] {
        return items.flatMap { [ $0.weight, $0.value ] }
    }
    
    func flattenPopulation(_ population: Population) -> [Int] {
        // Convert [Solution] to [[Int]]
        let arrayOfArrays = population.individuals.map { individual in
            individual.values.map { $0 ? Int(1) : Int(0) }
        }
    
        // Flatten [[Int]] into [Int]
        let flattenedArray = arrayOfArrays.flatMap { $0 }
    
        return flattenedArray
    }
    
    func convertToInt32Array(_ arr : [Int]) -> [Int32] {
        return arr.map { Int32($0) }
    }
    
    func generateItems(size: Int) -> [Itemm] {
        var items: [Itemm] = []
        for _ in 0..<size {
            items.append(Itemm())
        }
        return items
    }
    
    func writeRecordsAsCSV(records: [Record], filePath: String) {
        // Create CSV string with headers
        var csvString = "Algorithm,Population Size,Items Size,Calculation Time,NumberOfThreads\n"
        
        // Append each record in CSV format
        for record in records {
            let recordString = "\(record.algorithm),\(record.populationSize),\(record.itemsSize),\(record.calculationTime),\(record.numberOfThreads)\n"
            csvString += recordString
        }
        
        // Write CSV string to file
        do {
            try csvString.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing to file:", error)
        }
    }
}
