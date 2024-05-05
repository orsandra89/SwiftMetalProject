#include <metal_stdlib>
using namespace metal;

float randomFloat(uint seed) {
    // Implement a simple linear congruential generator (LCG) algorithm
    seed = (seed * 1664525u) + 1013904223u;
    
    // Convert the integer result to a float in the range [0.0f, 1.0f]
    return float(seed & 0x007FFFFF) * (1.0f / 8388608.0f);
}

int32_t fitness(device int32_t* population, int32_t pos, device int32_t* items, int32_t itemsCount, int32_t knapsackCapacity, int32_t maxSolutionSize, device int32_t* fitnessScores, int32_t populationSize, int32_t threadNumber) {
    // Evaluate fitness of the solution
    int32_t totalWeight = 0;
    int32_t totalValue = 0;
    for (int32_t p = 0; p < maxSolutionSize; p++) {
        totalWeight = totalWeight + (items[p * 2] * population[threadNumber * populationSize * maxSolutionSize + itemsCount * pos + p]);
        totalValue = totalValue + (items[p * 2 + 1] * population[threadNumber * populationSize * maxSolutionSize + itemsCount * pos + p]);
    }
    fitnessScores[threadNumber * populationSize + pos] = (totalWeight > knapsackCapacity) ? 0 : totalValue;
    return (totalWeight > knapsackCapacity) ? 0 : totalValue;
}

void crossover(device int32_t* population, int32_t parent1Pos, int32_t parent2Pos, device int32_t* childBuffer, int32_t maxSolutionSize, int32_t populationSize, int32_t threadNumber) {
    
    for (int32_t i = 0; i < maxSolutionSize; ++i) {
        childBuffer[threadNumber * maxSolutionSize + i] = i % 2 == 0 ? population[threadNumber * populationSize * maxSolutionSize + parent1Pos * maxSolutionSize + i] : population[threadNumber * populationSize * maxSolutionSize + parent2Pos * maxSolutionSize + i];
    }
}

void mutate(device int32_t* mutatedChildBuffer, device int32_t* childBuffer, float mutationRate, int32_t maxSolutionSize, uint seed, int32_t threadNumber) {
    for (int32_t i = 0; i < maxSolutionSize; ++i) {
        if (randomFloat(seed) < mutationRate) {
            mutatedChildBuffer[threadNumber * maxSolutionSize + i] = childBuffer[threadNumber * maxSolutionSize + i] ^ 1;
        } else {
            mutatedChildBuffer[threadNumber * maxSolutionSize + i] = childBuffer[threadNumber * maxSolutionSize + i];
        }
    }
}

kernel void geneticAlgorithm(device int32_t* population [[ buffer(0) ]],
                              device int32_t* newPopulation [[ buffer(10) ]],
                              device int32_t* childBuffer [[ buffer(11) ]],
                              device int32_t* mutatedChildBuffer [[ buffer(12) ]],
                              constant int32_t& populationSize [[ buffer(1) ]],
                              constant int32_t& generations [[ buffer(2) ]],
                              device int32_t* fitnessScores [[ buffer(3) ]],
                              device int32_t* bestSolution [[ buffer(4) ]],
                              device int32_t* items [[ buffer(5) ]],
                              constant int32_t& itemsCount [[ buffer(6) ]],
                              constant int32_t& knapsackCapacity [[ buffer(7) ]],
                              constant int32_t& maxSolutionSize [[ buffer(8) ]],
                              constant int32_t& mutationRate [[ buffer(9) ]],
                              constant uint& seed [[ buffer(13) ]],
                              device int32_t* threadsBuffer [[ buffer(14) ]],
                              uint threadID [[thread_position_in_threadgroup]]) {
    int32_t threadNumber = (int32_t)threadID;
    threadsBuffer[threadNumber] = threadNumber;

    for (int32_t gen = 0; gen < generations; ++gen) {

        // Evaluate fitness of each solution
        for (int32_t i = 0; i < populationSize; ++i) {
            fitnessScores[threadNumber * populationSize + i] = fitness(population, i, items, itemsCount, knapsackCapacity, maxSolutionSize, fitnessScores, populationSize, threadNumber);
        }
        
        // Select parents based on fitness
        int32_t parentIndex1 = 0;
        int32_t parentIndex2 = 0;
        float maxFitness = -1.0;
        for (int32_t i = 0; i < populationSize; ++i) {
            if (fitnessScores[threadNumber * populationSize + i] > maxFitness) {
                maxFitness = fitnessScores[threadNumber * populationSize + i];
                parentIndex1 = i;
            }
        }
        maxFitness = -1.0;
        for (int32_t i = 0; i < populationSize; ++i) {
            if (fitnessScores[threadNumber * populationSize + i] > maxFitness && i != parentIndex1) {
                maxFitness = fitnessScores[threadNumber * populationSize + i];
                parentIndex2 = i;
            }
        }
        
        // Generate new population through crossover and mutation
        int32_t newPopulationIndex = 0;

        for (int32_t l = 0; l < maxSolutionSize; l++) {
            newPopulation[threadNumber * populationSize * maxSolutionSize + newPopulationIndex * maxSolutionSize + l] = population[threadNumber * populationSize * maxSolutionSize + parentIndex1 * maxSolutionSize + l];
        }
        newPopulationIndex++;

        for (int32_t l = 0; l < maxSolutionSize; l++) {
            newPopulation[threadNumber * populationSize * maxSolutionSize + newPopulationIndex * maxSolutionSize + l] = population[threadNumber * populationSize * maxSolutionSize + parentIndex2 * maxSolutionSize + l];
        }
        newPopulationIndex++;

        while (newPopulationIndex < populationSize) {
            crossover(population, parentIndex1, parentIndex2, childBuffer, maxSolutionSize, populationSize, threadNumber);
            mutate(mutatedChildBuffer, childBuffer, mutationRate, maxSolutionSize, seed, threadNumber);
            for (int32_t l = 0; l < maxSolutionSize; l++) {
                newPopulation[threadNumber * populationSize * maxSolutionSize + newPopulationIndex * maxSolutionSize + l] = mutatedChildBuffer[threadNumber * maxSolutionSize + l];
            }
            newPopulationIndex++;
        }
        
        // Copy new population back
        for (int32_t i = 0; i < populationSize * maxSolutionSize; ++i) {
           population[threadNumber * populationSize * maxSolutionSize + i] = newPopulation[threadNumber * populationSize * maxSolutionSize + i];
        }
    }
    
    // Find the best solution
    float maxFitness = -1.0;
    for (int32_t i = 0; i < populationSize; ++i) {
        float currentFitness = fitness(population, i, items, itemsCount, knapsackCapacity, maxSolutionSize, fitnessScores, populationSize, threadNumber);
        if (currentFitness > maxFitness) {
            maxFitness = currentFitness;
            for (int32_t m = 0; m < maxSolutionSize; m++) {
                bestSolution[threadNumber * maxSolutionSize + m] = population[threadNumber * populationSize * maxSolutionSize + i * maxSolutionSize + m];
            }
        }
    }
}
