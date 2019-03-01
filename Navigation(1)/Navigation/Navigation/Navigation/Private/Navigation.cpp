#include "Navigation.h"


Navigation::Navigation()
{
	_map = nullptr;
}

Navigation::~Navigation()
{
}

inline INavigation * Navigation::Init(std::shared_ptr<IMap> map)
{
	_map = map;
	return this;
}

inline INavigation * Navigation::AddClose(std::unordered_set<long long>& close, int index1, int index2)
{
	if (index2 == -1)
		close.insert(index1);
	else
	{
		int len = _map->GetWidth() * _map->GetHeight();
		if (index1 > index2)
			close.insert(index1 * len + index2);
		else
			close.insert(index2 * len + index1);
	}
	return this;
}

inline bool Navigation::IsInClose(std::unordered_set<long long>& close, int index1, int index2)
{
	if (index2 == -1)
		return close.find(index1) != close.end();
	else
	{
		int len = _map->GetHeight() * _map->GetWidth();
		if (index1 > index2)
			return close.find(index1 * len + index2) != close.end();
		else
			return close.find(index2 * len + index1) != close.end();
	}
}

inline int Navigation::ExpectDistance(int index1, int index2)
{
	int x = abs(_map->GetX(index1) - _map->GetX(index2));
	int y = abs(_map->GetY(index1) - _map->GetY(index2));
	return std::min(x, y) * 14 + abs(x - y) * 10;
}

inline int Navigation::CalcuDistance(int index1, int index2, int dps, int speed)
{
	int h = _map->GetGround(index2)->GetHeight();
	int dis = ExpectDistance(index1, index2);
	return dis + h / dps * speed;
}

INavigation * Navigation::AddOpen(std::priority_queue<std::shared_ptr<IDistance>>& open, std::shared_ptr<IDistance>& o)
{
	open.push(o);
	return this;
}
