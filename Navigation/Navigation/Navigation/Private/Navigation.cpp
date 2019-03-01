#include "Navigation.h"

template<typename M, typename D>
Navigation<M,D>::Navigation()
{
	_map = nullptr;
}

template<typename M, typename D>
Navigation<M, D>::~Navigation()
{
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::Init(std::shared_ptr<M> map)
{
	_map = map;
	return this;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::AddClose(std::unordered_set<long long>& close, int index1, int index2)
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

template<typename M, typename D>
inline bool Navigation<M, D>::IsInClose(std::unordered_set<long long>& close, int index1, int index2)
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

template<typename M, typename D>
inline int Navigation<M, D>::ExpectDistance(int index1, int index2)
{
	int x = abs(_map->GetX(index1) - _map->GetX(index2));
	int y = abs(_map->GetY(index1) - _map->GetY(index2));
	return std::min(x, y) * 14 + abs(x - y) * 10;
}

template<typename M, typename D>
inline int Navigation<M, D>::CalcuDistance(int index1, int index2, int dps, int speed)
{
	int h = _map->GetGround(index2)->GetHeight();
	int dis = ExpectDistance(index1, index2);
	return dis + h / dps * speed;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::AddOpen(std::priority_queue<std::shared_ptr<D>>& open, std::shared_ptr<D>& o)
{
	open.push(o);
	return this;
}
