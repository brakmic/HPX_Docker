#include <hpx/hpx_main.hpp>
#include <hpx/include/parallel_sort.hpp>
#include <vector>
#include <algorithm>
#include <iostream>

int main()
{
    // Initialize a vector with unsorted integers
    std::vector<int> data = {50, 20, 40, 10, 30};

    std::cout << "Before HPX sort: ";
    for(auto num : data)
        std::cout << num << " ";
    std::cout << std::endl;

    // Perform parallel sort using HPX
    hpx::sort(hpx::execution::par, data.begin(), data.end());

    std::cout << "After HPX sort: ";
    for(auto num : data)
        std::cout << num << " ";
    std::cout << std::endl;

    return 0;
}
