import Foundation

class ConcreteStrategyA: Strategy {

    // Function to perform crossover between two solutions
    func crossover(parent1: Individual, parent2: Individual) -> Individual {
        let crossoverPoint = Int.random(in: Int(0)..<Int(parent1.values.count))
        let child = parent1.values.prefix(crossoverPoint) + parent2.values.suffix(parent2.values.count - crossoverPoint)
        return Individual(values: Array(child))
    }

    // Function to perform mutation on a solution
    func mutate(individual: Individual) -> Individual {
        let mutationRate: Float = 0.1
        return Individual(values: individual.values.map { bit in
            if Float.random(in: 0..<1) < mutationRate {
                return !bit
            } else {
                return bit
            }
        })
    }

    func doAlgorithm(p: Population, items: [Itemm], generations: Int, knapsackCapacity: Int, numberOfThreads:Int) -> (Individual, Double) {
        var population = p

        let startTime = DispatchTime.now()
    
        for _ in 0..<generations {
            
            // Select parents based on fitness
            let (parent1, parent2) = population.findBestCandidates(items: items, weightLimit: knapsackCapacity)
            
            // Generate new population through crossover and mutation
            var newPopulation = [parent1, parent2]
            while newPopulation.count < population.populationSize {
                let child = crossover(parent1: parent1, parent2: parent2)
                newPopulation.append(mutate(individual: child))
            }
            
            population = Population(individuals: newPopulation)
        }
        let endTime = DispatchTime.now()
        
        let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        // Return the best solution
        return (population.findBestCandidate(items: items, weightLimit: knapsackCapacity), elapsedTime)
    }
}
