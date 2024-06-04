import Foundation

extension Array where Element == Int {
    func argmax() -> Int? {
        guard let maxElement = self.max() else {
            return nil
        }
        return firstIndex(of: maxElement)
    }
}

class Population {
    var individuals: [Individual]
    let populationSize: Int

    init(populationSize: Int, chromosomes: Int) {
        self.individuals = (0..<populationSize).map { _ in Individual(size: chromosomes) }
        self.populationSize = populationSize
    }
    
    init(individuals: [Individual]) {
        self.individuals = individuals
        self.populationSize = individuals.count
    }

    func findBestCandidates(items: [Itemm], weightLimit: Int) -> (Individual, Individual) {
        let fitnessScores = self.individuals.map { solution in
            return solution.calculateFitness(items: items, weightLimit: weightLimit)
        }
        
        // Select parents based on fitness
        let parent1 = self.individuals[Int(fitnessScores.argmax()!)]
        let parent2 = self.individuals[Int(fitnessScores.argmax()!)]

        return (parent1, parent2)
    }

    func findBestCandidate(items: [Itemm], weightLimit: Int) -> Individual {
        let fitnessScores = self.individuals.map { solution in
            return solution.calculateFitness(items: items, weightLimit: weightLimit)
        }
        
        return self.individuals[Int(fitnessScores.argmax()!)]
    }
}
