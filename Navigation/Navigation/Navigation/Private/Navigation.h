#pragma once

#include "..\Public\INavigation.h"

#define WALL_MAX_DISTANCE 80

namespace NS_Navigation {

	template<typename M, typename D>
	class Navigation : public INavigation<M, D>
	{
	public:
		using ptrM = typename INavigation<M, D>::ptrM;
		using ptrD = typename INavigation<M, D>::ptrD;
		using Compare = typename INavigation<M, D>::Compare;


		Navigation() : INavigation<M, D>(), _map(nullptr) {
		};
		virtual ~Navigation() {
		};

		inline virtual Navigation<M, D> * Init(std::shared_ptr<M> & map);

		inline virtual std::shared_ptr<M> GetMap();

		inline virtual Navigation<M, D> * AddOpen(std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, Compare> & open, std::shared_ptr<D> & o);

		inline virtual Navigation<M, D> * AddClose(std::unordered_set<int> & close, int index1, int index2 = -1);

		inline virtual bool IsInClose(std::unordered_set<int> & close, int index1, int index2 = -1);

		inline virtual int ExpectDistance(int index1, int index2);

		inline virtual int CalcuDistance(int index1, int index2, int dps, int speed);

		inline virtual Navigation<M, D> * AddAttraction(std::vector<int> & path);

	private:

		std::shared_ptr<M> _map;

	};

	template<typename M, typename D>
	std::shared_ptr<M> Navigation<M, D>::GetMap()
	{
		return _map;
	}

	template<typename M, typename D>
	Navigation<M, D> * Navigation<M, D>::Init(std::shared_ptr<M> & map)
	{
		_map = map;
		return this;
	}

	template<typename M, typename D>
	Navigation<M, D> * Navigation<M, D>::AddOpen(std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, Compare> & open, std::shared_ptr<D>& o)
	{
		open.push(o);
		return this;
	}

	template<typename M, typename D>
	Navigation<M, D> * Navigation<M, D>::AddClose(std::unordered_set<int>& close, int index1, int index2)
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
	bool Navigation<M, D>::IsInClose(std::unordered_set<int>& close, int index1, int index2)
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
	int Navigation<M, D>::ExpectDistance(int index1, int index2)
	{
		int x = abs(_map->GetX(index1) - _map->GetX(index2));
		int y = abs(_map->GetY(index1) - _map->GetY(index2));
		return min(x, y) * 14 + abs(x - y) * 10;
	}

	template<typename M, typename D>
	int Navigation<M, D>::CalcuDistance(int index1, int index2, int dps, int speed)
	{
		auto g = _map->GetGround(index2);
		int h = g->GetHeight();
		int dis = ExpectDistance(index1, index2);
		if (h == 0)
			return dis;
		int a = g->GetAttraction();
		return dis + min((((h - a) / dps) + 1) * speed, WALL_MAX_DISTANCE);
	}

	template<typename M, typename D>
	Navigation<M, D> * Navigation<M, D>::AddAttraction(std::vector<int> & path)
	{
		for (auto index : path)
		{
			auto g = _map->GetGround(index);
			int h = g->GetHeight();
			if (h > 0)
				g->SetAttraction(h);
		}
		return this;
	}

}