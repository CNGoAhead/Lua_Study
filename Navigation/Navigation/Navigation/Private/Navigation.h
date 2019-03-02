#pragma once

#include "..\Public\INavigation.h"

template<typename M, typename D>
class Navigation : public INavigation<M, D>
{
public:
	using ptrM = std::shared_ptr<M>;
	using ptrD = std::shared_ptr<D>;

	Navigation() : INavigation<M, D>(), _map(nullptr) {
	};
	virtual ~Navigation() {
	};

	virtual INavigation<M, D> * Init(std::shared_ptr<M> & map);

	virtual std::shared_ptr<M> & GetMap();

	virtual INavigation<M, D> * AddOpen(std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::shared_ptr<D> & o);

	virtual INavigation<M, D> * AddClose(std::unordered_set<int> & close, int index1, int index2 = -1);

	virtual bool IsInClose(std::unordered_set<int> & close, int index1, int index2 = -1);

	virtual int ExpectDistance(int index1, int index2);

	virtual int CalcuDistance(int index1, int index2, int dps, int speed);

	virtual INavigation<M, D> * ClearMoveGroundHeight(std::vector<int> & path);

	virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration) = 0;

	virtual std::vector<int> FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration) = 0;

	virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> ends, int dps, int speed, int duration) = 0;

	virtual std::vector<int> ResumeSearch(int searchId) = 0;

private:

	std::shared_ptr<M> _map;

};

template<typename M , typename D>
std::shared_ptr<M> & Navigation<M, D>::GetMap()
{
	return _map;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::Init(std::shared_ptr<M> & map)
{
	_map = map;
	return this;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::AddOpen(std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::shared_ptr<D>& o)
{
	open.push(o);
	return this;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::AddClose(std::unordered_set<int>& close, int index1, int index2)
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
inline bool Navigation<M, D>::IsInClose(std::unordered_set<int>& close, int index1, int index2)
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
	return min(x, y) * 14 + abs(x - y) * 10;
}

template<typename M, typename D>
inline int Navigation<M, D>::CalcuDistance(int index1, int index2, int dps, int speed)
{
	int h = _map->GetGround(index2)->GetHeight();
	int dis = ExpectDistance(index1, index2);
	return dis + h / dps * speed;
}

template<typename M, typename D>
inline INavigation<M, D> * Navigation<M, D>::ClearMoveGroundHeight(std::vector<int> & path)
{
	for (auto p : path)
	{
		auto g = _map->GetGround(p);
		if (g && g->GetHeight() > 0)
			g->SetHeight(0);
	}
	return this;
}
