//import Foundation
//import XCTest

//class StrategyConceptual: XCTestCase {
struct MyApp {
    func testitemchange() {
        
        /// The client code picks a concrete strategy and passes it to the
        /// context. The client should be aware of the differences between
        /// strategies in order to make the right choice.
        //        let items = [
        //            Itemm(weight: Int(10), value: Int(60)),
        //            Itemm(weight: Int(20), value: Int(100)),
        //            Itemm(weight: Int(30), value: Int(120))
        //        ]
                
        
        var records: [Record] = []
        
        let strategy = ConcreteStrategyA()
        print("Client: Strategy is set to Sequential algorithm.\n")
        for i in 0..<10 {
            let items = Converter.shared.generateItems(size: 100 + i*10)
            let (_, elapsedTime) = strategy.doAlgorithm(p: Population(populationSize: 10000, chromosomes: items.count), items: items, generations: Int(20), knapsackCapacity: Int(50), numberOfThreads:Int(1))
            
            records.append(Record(algorithm: "Sequential", populationSize: 10000, itemsSize: items.count, calculationTime: elapsedTime, numberOfThreads: 1))
        }
        
        Converter.shared.writeRecordsAsCSV(records: records, filePath: "sequential_item_change.csv")
        
//        print("Calculation time: \(elapsedTime)")
//        
//        print("Best solution: \(bestSolution.values)")
        
    }
//}
    
    func testpopulationchange() {
        
        /// The client code picks a concrete strategy and passes it to the
        /// context. The client should be aware of the differences between
        /// strategies in order to make the right choice.
        //        let items = [
        //            Itemm(weight: Int(10), value: Int(60)),
        //            Itemm(weight: Int(20), value: Int(100)),
        //            Itemm(weight: Int(30), value: Int(120))
        //        ]
                
        let items = Converter.shared.generateItems(size: 100)
        
        var records: [Record] = []
        
        let strategy = ConcreteStrategyA()
        print("Client: Strategy is set to Sequential algorithm.\n")
        for i in 0..<10 {
            let populationSize = 10000 + i * 1000
            let (_, elapsedTime) = strategy.doAlgorithm(p: Population(populationSize: populationSize, chromosomes: items.count), items: items, generations: Int(20), knapsackCapacity: Int(50), numberOfThreads: 1)
            
            records.append(Record(algorithm: "Sequential", populationSize: populationSize, itemsSize: items.count, calculationTime: elapsedTime, numberOfThreads: 1))
        }
        
        Converter.shared.writeRecordsAsCSV(records: records, filePath: "sequential_population_change.csv")
        
//        print("Calculation time: \(elapsedTime)")
//
//        print("Best solution: \(bestSolution.values)")
        
    }

}

