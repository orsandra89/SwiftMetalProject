#include <metal_stdlib>
using namespace metal;

kernel void findMax(const device int* input [[buffer(0)]],
                    device int* output [[buffer(1)]],
                    uint id [[thread_position_in_grid]]) {
    const uint listLength = 10; // Length of each list
    
    // Extract the list
    thread int list[listLength];
    for (uint i = 0; i < listLength; ++i) {
        list[i] = input[id * listLength + i];
    }
    
    // Find max element
    int maxElement = list[0];
    for (uint i = 1; i < listLength; ++i) {
        maxElement = max(maxElement, list[i]);
    }
    
    // Store the max element
    output[id] = maxElement;
}