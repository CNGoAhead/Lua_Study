#include "Map.h"

IMap * Map::Init(int w, int h, std::unordered_map<std::pair<int, int>, int> hight, std::unordered_map<std::pair<int, int>, int> flag)
{
	_w = w;
	_h = h;
	_grounds.reserve(_w * _h);
	return this;
}
