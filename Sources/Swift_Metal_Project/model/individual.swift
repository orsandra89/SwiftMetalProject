import Foundation

class Individual {
    var values: [Bool]
    let size: Int
    
    init(size: Int) {
        self.size = size
        self.values = (0..<size).map { _ in Bool.random() }
    }

    init(values: [Bool]) {
        self.values = values
        self.size = values.count
    }

    func calculateFitness(items: [Itemm], weightLimit: Int) -> Int {
        // Calculate fitness value based on the provided list of items
        var totalWeight = 0
        var totalValue = 0
        
        for i in 0..<values.count {
            if values[i] {
                totalWeight += items[i].weight
                totalValue += items[i].value
            }
        }

        return totalWeight > weightLimit ? 0 : totalValue
    }
}
