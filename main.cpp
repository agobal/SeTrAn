#include <iostream>
#include <fstream>

int main()
{
	std::ifstream NodeFile ("nodes.txt");
	std::ifstream ElFile ("bars.txt");
	int number_of_nodes = 0;
	int number_of_bars = 0;
	std::string node;
	while (std::getline(NodeFile, node))
		++number_of_nodes;
	std::string bar;
	while (std::getline(ElFile, bar))
		++number_of_bars;
	std::cout << number_of_nodes;
	std::cout << number_of_bars;
}
