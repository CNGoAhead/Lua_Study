#pragma once

#include "Navigation.h"

#include "../TimeCost.h"

namespace NS_Navigation {

	template<typename M, typename D>
	class AStarNavigation : public Navigation<M, D>
	{
	public:
		using ptrM = typename INavigation<M, D>::ptrM;
		using ptrD = typename INavigation<M, D>::ptrD;
		using Compare = typename INavigation<M, D>::Compare;


	private:
		class INavigationCache
		{
		public:
			enum class ENavType { Normal, Multi, Flag };
			INavigationCache(ENavType type)
				: _type(type) {
			}
			virtual ~INavigationCache() {
			}
			ENavType _type;
		};

		class NavigationCache_Normal : public INavigationCache
		{
		public:
			NavigationCache_Normal(int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Normal), eindex(eindex), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			int eindex;
			int dps;
			int speed;
			std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
			std::unordered_set<int> close;
			std::unordered_map<int, int> minMap;
		};

		class NavigationCache_Multi : public INavigationCache
		{
		public:
			NavigationCache_Multi(std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Multi), eindexs(eindexs), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			std::unordered_set<int> eindexs;
			int dps;
			int speed;
			std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
			std::unordered_set<int> close;
			std::unordered_map<int, int> minMap;
		};

		struct NavigationCache_Flag : public INavigationCache
		{
			NavigationCache_Flag(unsigned short flag, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Flag), flag(flag), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			unsigned short flag;
			int dps;
			int speed;
			std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
			std::unordered_set<int> close;
			std::unordered_map<int, int> minMap;
		};

	public:
		using ptrM = typename INavigation<M, D>::ptrM;
		using ptrD = typename INavigation<M, D>::ptrD;
		using Compare = typename INavigation<M, D>::Compare;

		AStarNavigation() : Navigation<M, D>() {
		};
		~AStarNavigation() {
		};

		inline virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration = -1) override;

#ifdef DEBUG

		inline virtual std::vector<int> NormalSearch(int sx, int sy, int ex, int ey, int dps, int speed, int duration = -1);

#endif // DEBUG

		inline virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration = -1) override;

		inline virtual std::vector<int> FlagSearch(int sx, int sy, unsigned short flag, int dps, int speed, int duration = -1) override;

		inline virtual std::vector<int> ResumeSearch(int searchId, int duration = -1) override;

	private:

		inline virtual ptrD Search(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD MultiSearch(std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD FlagSearch(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD BFS(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close);

		inline virtual std::vector<ptrD> GetOpensWithDir(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close);

		inline virtual ptrD BFS(std::unordered_set<int> eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close);

		inline virtual std::vector<ptrD> GetOpensWithDir(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close);

		inline virtual AStarNavigation<M, D> * AddOpen(std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, ptrD & l, ptrD & o, std::unordered_map<int, int> & minMap);

		inline virtual ptrD BFS(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(int sindex, int dps, int speed, std::unordered_set<int> & close);

		inline virtual int ExpectDistance(int index1, std::unordered_set<int> & index2s);

		inline virtual std::vector<int> GetPath(ptrD cur);

		inline virtual std::vector<int> SaveCache(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<int> SaveCache(std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<int> SaveCache(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

	private:

		std::vector<std::shared_ptr<INavigationCache>> _cache;

	};

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::FlagSearch(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		while (!Navigation<M, D>::GetMap()->GetGround(sindex)->HasFlag(flag) && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(flag, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
		}
		return cur;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::MultiSearch(std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		while (eindexs.find(sindex) == eindexs.end() && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(eindexs, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
		}
		return cur;
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Flag(flag, dps, speed, open, close, minMap)));
		return { -int(_cache.size()) };
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Multi(eindexs, dps, speed, open, close, minMap)));
		return { -int(_cache.size()) };
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Normal(eindex, dps, speed, open, close, minMap)));
		return { -int(_cache.size()) };
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::GetPath(ptrD cur)
	{
		std::vector<int> path;
		D* p = cur.get();

		while (p)
		{
			path.push_back(p->GetIndex());
			p = dynamic_cast<D*>(p->GetLast().get());
		}
		std::reverse(path.begin(), path.end());

		Navigation<M, D>::AddWallAttraction(path);
		
		return path;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::Search(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		while (sindex != eindex && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(eindex, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
		}
		return cur;
	}

#ifdef DEBUG

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::NormalSearch(int sx, int sy, int ex, int ey, int dps, int speed, int duration /*= -1*/)
	{
		int sindex = Navigation<M, D>::GetMap()->GetIndex(sx, sy);
		int eindex = Navigation<M, D>::GetMap()->GetIndex(ex, ey);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, Navigation<M, D>::ExpectDistance(sindex, eindex));
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = open.top();
		sindex = cur->GetIndex();
		while (sindex != eindex && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(eindex, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
		}

		std::vector<int> path;
		D* p = cur.get();

		while (p)
		{
			path.push_back(p->GetIndex());
			p = dynamic_cast<D*>(p->GetLast().get());
		}
		std::reverse(path.begin(), path.end());

		Navigation<M, D>::AddWallAttraction(path);

		return path;
	}

#endif // DEBUG

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = Navigation<M, D>::GetMap();
		int x = map->GetX(sindex);
		int y = map->GetY(sindex);
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || Navigation<M, D>::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), 0);
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sindex, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (Navigation<M, D>::GetMap()->GetGround(c->GetIndex())->HasFlag(flag))
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
		}
		if (open.empty())
			return nullptr;
		return open.top();
	}

	template<typename M, typename D>
	int AStarNavigation<M, D>::ExpectDistance(int index1, std::unordered_set<int> & index2s)
	{
		std::priority_queue<int> bheap;
		for (auto index2 : index2s)
		{
			bheap.push(Navigation<M, D>::ExpectDistance(index1, index2));
		}
		return bheap.top();
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithDir(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close)
	{
		std::vector<ptrD> ret;
		std::vector<int> vec;
		std::unordered_set<int> set;
		for (auto eindex : eindexs)
		{
			int sx = Navigation<M, D>::GetMap()->GetX(sindex);
			int sy = Navigation<M, D>::GetMap()->GetY(sindex);
			int ex = Navigation<M, D>::GetMap()->GetX(eindex);
			int ey = Navigation<M, D>::GetMap()->GetY(eindex);
			int difx = ex - sx;
			int dify = ey - sy;

			if (abs(difx) != abs(dify))
			{
				if (abs(difx) > abs(dify))
					vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx + difx / abs(difx), sy));
				else
					vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx, sy + dify / abs(dify)));
			}

			if (difx != 0 || dify != 0)
				vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx + difx / max(abs(difx), 1), sy + dify / max(abs(dify), 1)));
		}

		for (int index : vec)
		{
			if (Navigation<M, D>::IsInClose(close, sindex, index) || set.find(index) != set.end())
				continue;
			set.insert(index);
			auto g = Navigation<M, D>::GetMap()->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), ExpectDistance(index, eindexs));
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = Navigation<M, D>::GetMap();
		int x = map->GetX(sindex);
		int y = map->GetY(sindex);
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || Navigation<M, D>::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), ExpectDistance(index, eindexs));
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(std::unordered_set<int> eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sindex, eindexs, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (eindexs.find(c->GetIndex()) != eindexs.end())
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
		}
		if (open.empty())
			return nullptr;
		return open.top();
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithDir(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close)
	{
		std::vector<ptrD> ret;
		std::vector<int> vec;
		int sx = Navigation<M, D>::GetMap()->GetX(sindex);
		int sy = Navigation<M, D>::GetMap()->GetY(sindex);
		int ex = Navigation<M, D>::GetMap()->GetX(eindex);
		int ey = Navigation<M, D>::GetMap()->GetY(eindex);
		int difx = ex - sx;
		int dify = ey - sy;

		if (abs(difx) != abs(dify))
		{
			if (abs(difx) > abs(dify))
				vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx + difx / abs(difx), sy));
			else
				vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx, sy + dify / abs(dify)));
		}

		if (difx != 0 || dify != 0)
			vec.push_back(Navigation<M, D>::GetMap()->GetIndex(sx + difx / max(abs(difx), 1), sy + dify / max(abs(dify), 1)));

		for (int index : vec)
		{
			if (Navigation<M, D>::IsInClose(close, sindex, index))
				continue;
			auto g = Navigation<M, D>::GetMap()->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), Navigation<M, D>::ExpectDistance(index, eindex));
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration)
	{
		int sindex = Navigation<M, D>::GetMap()->GetIndex(sx, sy);
		int eindex = Navigation<M, D>::GetMap()->GetIndex(ex, ey);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, Navigation<M, D>::ExpectDistance(sindex, eindex));
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = Search(eindex, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (cur->GetIndex() == eindex)
			return GetPath(cur);
		else
			return SaveCache(eindex, open, close, minMap, dps, speed);
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::FlagSearch(int sx, int sy, unsigned short flag, int dps, int speed, int duration)
	{
		int sindex = Navigation<M, D>::GetMap()->GetIndex(sx, sy);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, 0);
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = FlagSearch(flag, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (Navigation<M, D>::GetMap()->GetGround(cur->GetIndex())->HasFlag(flag))
			return GetPath(cur);
		else
			return SaveCache(flag, open, close, minMap, dps, speed);
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration)
	{
		int sindex = Navigation<M, D>::GetMap()->GetIndex(sx, sy);
		std::unordered_set<int> eindexs;
		for (auto p : ends)
			eindexs.insert(Navigation<M, D>::GetMap()->GetIndex(p.first, p.second));
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, ExpectDistance(sindex, eindexs));
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = MultiSearch(eindexs, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (eindexs.find(cur->GetIndex()) != eindexs.end())
			return GetPath(cur);
		else
			return SaveCache(eindexs, open, close, minMap, dps, speed);
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::ResumeSearch(int searchId, int duration)
	{
		ptrD cur;
		int saveId = -(searchId + 1);
		if (saveId >= 0 && saveId < _cache.size())
		{
			int etime = -1;
			if (duration > 0)
				etime = ::GetTickCount() + duration;
			NavigationCache_Normal * p1;
			NavigationCache_Multi * p2;
			NavigationCache_Flag * p3;
			auto save = _cache[saveId];
			switch (save->_type)
			{
			case INavigationCache::ENavType::Normal:
				p1 = dynamic_cast<NavigationCache_Normal*>(save.get());
				if (p1)
					cur = Search(p1->eindex, p1->open, p1->close, p1->minMap, p1->dps, p1->speed, etime);
				if (cur && cur->GetIndex() == p1->eindex)
					return GetPath(cur);
				break;
			case INavigationCache::ENavType::Multi:
				p2 = dynamic_cast<NavigationCache_Multi*>(save.get());
				if (p2)
					cur = MultiSearch(p2->eindexs, p2->open, p2->close, p2->minMap, p2->dps, p2->speed, etime);
				if (cur && p2->eindexs.find(cur->GetIndex()) != p2->eindexs.end())
					return GetPath(cur);
				break;
			case INavigationCache::ENavType::Flag:
				p3 = dynamic_cast<NavigationCache_Flag*>(save.get());
				if (p3)
					cur = FlagSearch(p3->flag, p3->open, p3->close, p3->minMap, p3->dps, p3->speed, etime);
				if (cur && Navigation<M, D>::GetMap()->GetGround(cur->GetIndex())->HasFlag(p3->flag))
					return GetPath(cur);
				break;
			default:
				break;
			}
		}
		if (!cur)
			return {};
		else
			return { searchId };
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sindex, eindex, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (c->GetIndex() == eindex)
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
		}
		if (open.empty())
			return nullptr;
		return open.top();
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = Navigation<M, D>::GetMap();
		int x = map->GetX(sindex);
		int y = map->GetY(sindex);
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || Navigation<M, D>::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), Navigation<M, D>::ExpectDistance(index, eindex));
			}
		}
		return ret;
	}

	template<typename M, typename D>
	AStarNavigation<M, D> * AStarNavigation<M, D>::AddOpen(std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, ptrD & l, ptrD & o, std::unordered_map<int, int> & minMap)
	{
		*o += *l;
		if (minMap[o->GetIndex()] == 0 || o->GetWalk() < minMap[o->GetIndex()])
		{
			o->SetLast(l);
			minMap[o->GetIndex()] = o->GetWalk();
			Navigation<M, D>::AddOpen(open, o);
		}
		return this;
	}

}