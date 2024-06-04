protocol Strategy {

    func doAlgorithm(p: Population, items: [Itemm], generations: Int, knapsackCapacity: Int, numberOfThreads:Int) -> (Individual, Double)
}
