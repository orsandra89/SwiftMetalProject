import Foundation

class Itemm {
    let weight: Int
    let value: Int
    
    init() {
        self.weight = Int.random(in: 1...100)
        self.value = Int.random(in: 1...100)
    }
    
    init(weight: Int, value: Int) {
        self.weight = weight
        self.value = value
    }
}
