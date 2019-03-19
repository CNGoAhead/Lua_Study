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
			NavigationCache_Normal(float sx, float sy, int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Normal), sx(sx), sy(sy), eindex(eindex), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			float sx;
			float sy;
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
			NavigationCache_Multi(float sx, float sy, std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Multi), sx(sx), sy(sy), eindexs(eindexs), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			float sx;
			float sy;
			std::unordered_set<int> eindexs;
			int dps;
			int speed;
			std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
			std::unordered_set<int> close;
			std::unordered_map<int, int> minMap;
		};

		struct NavigationCache_Flag : public INavigationCache
		{
			NavigationCache_Flag(float sx, float sy, unsigned short flag, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
				: INavigationCache(INavigationCache::ENavType::Flag), sx(sx), sy(sy), flag(flag), dps(dps), speed(speed), open(open), close(close), minMap(minMap)
			{
			}
			float sx;
			float sy;
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

		inline virtual std::vector<int> Search(float sx, float sy, int ex, int ey, int dps, int speed, int duration = -1) override;

#ifdef DEBUG

		inline virtual std::vector<int> NormalSearch(int sx, int sy, int ex, int ey, int dps, int speed, int duration = -1);

#endif // DEBUG

		inline virtual std::vector<int> MultiSearch(float sx, float sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration = -1) override;

		inline virtual std::vector<int> FlagSearch(float sx, float sy, unsigned short flag, int dps, int speed, int duration = -1) override;

		inline virtual std::vector<int> ResumeSearch(int searchId, int duration = -1) override;

	private:

		inline virtual ptrD Search(float & sx, float & sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD MultiSearch(float & sx, float & sy, std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD FlagSearch(float & sx, float & sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime);

		inline virtual ptrD BFS(float & sx, float & sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(float & sx, float & sy, int eindex, int dps, int speed, std::unordered_set<int> & close);

		inline virtual ptrD BFS(float & sx, float & sy, std::unordered_set<int> eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(float & sx, float & sy, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close);

		inline virtual AStarNavigation<M, D> * AddOpen(std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, ptrD & l, ptrD & o, std::unordered_map<int, int> & minMap);

		inline virtual ptrD BFS(float & sx, float & sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<ptrD> GetOpensWithNear(float & sx, float & sy, int dps, int speed, std::unordered_set<int> & close);

		inline virtual int ExpectDistance(int index1, std::unordered_set<int> & index2s);

		inline virtual std::vector<int> GetPath(ptrD cur);

		inline virtual std::vector<int> SaveCache(float sx, float sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<int> SaveCache(float sx, float sy, std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

		inline virtual std::vector<int> SaveCache(float sx, float sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed);

	private:

		std::vector<std::shared_ptr<INavigationCache>> _cache;

	};

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::FlagSearch(float & sx, float & sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		auto map = __super::GetMap();
		while (!__super::GetMap()->GetGround(sindex)->HasFlag(flag) && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(sx, sy, flag, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
			sx = map->GetX(sindex);
			sy = map->GetY(sindex);
		}
		return cur;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::MultiSearch(float & sx, float & sy, std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		auto map = __super::GetMap();
		while (eindexs.find(sindex) == eindexs.end() && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(sx, sy, eindexs, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
			sx = map->GetX(sindex);
			sy = map->GetY(sindex);
		}
		return cur;
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(float sx, float sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Flag(sx, sy, flag, dps, speed, open, close, minMap)));
		return { -int(_cache.size()) };
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(float sx, float sy, std::unordered_set<int> & eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Multi(sx, sy, eindexs, dps, speed, open, close, minMap)));
		return { -int(_cache.size()) };
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::SaveCache(float sx, float sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		_cache.push_back(std::shared_ptr<INavigationCache>(new NavigationCache_Normal(sx, sy, eindex, dps, speed, open, close, minMap)));
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

		__super::ClearMoveGroundHeight(path);
		
		return path;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::Search(float & sx, float & sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed, int etime)
	{
		auto cur = open.top();
		int sindex = cur->GetIndex();
		auto  map = __super::GetMap();
		while (sindex != eindex && (etime <= 0 || ::GetTickCount() > etime))
		{
			cur = BFS(sx, sy, eindex, open, close, minMap, dps, speed);
			if (!cur)
				break;
			sindex = cur->GetIndex();
			sx = map->GetX(sindex);
			sy = map->GetY(sindex);
		}
		return cur;
	}

#ifdef DEBUG

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::NormalSearch(int sx, int sy, int ex, int ey, int dps, int speed, int duration /*= -1*/)
	{
		int sindex = __super::GetMap()->GetIndex(sx, sy);
		int eindex = __super::GetMap()->GetIndex(ex, ey);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, __super::ExpectDistance(sindex, eindex));
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

		__super::ClearMoveGroundHeight(path);

		return path;
	}

#endif // DEBUG

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(float & sx, float & sy, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = __super::GetMap();
		int sindex = map->GetIndex(sx, sy);
		int x = sx;
		int y = sy;
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || __super::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, __super::CalcuDistance(sx, sy, index, dps, speed), 0);
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(float & sx, float & sy, unsigned short flag, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sx, sy, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (__super::GetMap()->GetGround(c->GetIndex())->HasFlag(flag))
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			__super::AddClose(close, sindex, c->GetIndex());
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
			bheap.push(__super::ExpectDistance(index1, index2));
		}
		return bheap.top();
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(float & sx, float & sy, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = __super::GetMap();
		int sindex = map->GetIndex(sx, sy);
		int x = sx;
		int y = sy;
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || __super::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, __super::CalcuDistance(sx, sy, index, dps, speed), ExpectDistance(index, eindexs));
			}
		}
		return ret;
	}

	template<typename M, typename D>
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(float & sx, float & sy, std::unordered_set<int> eindexs, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sx, sy, eindexs, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (eindexs.find(c->GetIndex()) != eindexs.end())
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			__super::AddClose(close, sindex, c->GetIndex());
		}
		if (open.empty())
			return nullptr;
		return open.top();
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::Search(float sx, float sy, int ex, int ey, int dps, int speed, int duration)
	{
		int sindex = __super::GetMap()->GetIndex(sx, sy);
		int eindex = __super::GetMap()->GetIndex(ex, ey);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, __super::ExpectDistance(sindex, eindex));
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = Search(sx, sy, eindex, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (cur->GetIndex() == eindex)
			return GetPath(cur);
		else
			return SaveCache(sx, sy, eindex, open, close, minMap, dps, speed);
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::FlagSearch(float sx, float sy, unsigned short flag, int dps, int speed, int duration)
	{
		int sindex = __super::GetMap()->GetIndex(sx, sy);
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, 0);
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = FlagSearch(sx, sy, flag, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (__super::GetMap()->GetGround(cur->GetIndex())->HasFlag(flag))
			return GetPath(cur);
		else
			return SaveCache(sx, sy, flag, open, close, minMap, dps, speed);
	}

	template<typename M, typename D>
	std::vector<int> AStarNavigation<M, D>::MultiSearch(float sx, float sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration)
	{
		int sindex = __super::GetMap()->GetIndex(sx, sy);
		std::unordered_set<int> eindexs;
		for (auto p : ends)
			eindexs.insert(__super::GetMap()->GetIndex(p.first, p.second));
		std::priority_queue<ptrD, std::vector<ptrD>, Compare> open;
		std::unordered_set<int> close;
		std::unordered_map<int, int> minMap;
		auto d = ptrD(new D());
		d->Init(sindex, 0, ExpectDistance(sindex, eindexs));
		open.push(d);

		int etime = -1;
		if (duration > 0)
			etime = ::GetTickCount() + duration;

		auto cur = MultiSearch(sx, sy, eindexs, open, close, minMap, dps, speed, etime);

		if (!cur)
			return {};
		else if (eindexs.find(cur->GetIndex()) != eindexs.end())
			return GetPath(cur);
		else
			return SaveCache(sx, sy, eindexs, open, close, minMap, dps, speed);
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
					cur = Search(p1->sx, p1->sy, p1->eindex, p1->open, p1->close, p1->minMap, p1->dps, p1->speed, etime);
				if (cur && cur->GetIndex() == p1->eindex)
					return GetPath(cur);
				break;
			case INavigationCache::ENavType::Multi:
				p2 = dynamic_cast<NavigationCache_Multi*>(save.get());
				if (p2)
					cur = MultiSearch(p2->sx, p2->sy, p2->eindexs, p2->open, p2->close, p2->minMap, p2->dps, p2->speed, etime);
				if (cur && p2->eindexs.find(cur->GetIndex()) != p2->eindexs.end())
					return GetPath(cur);
				break;
			case INavigationCache::ENavType::Flag:
				p3 = dynamic_cast<NavigationCache_Flag*>(save.get());
				if (p3)
					cur = FlagSearch(p3->sx, p3->sy, p3->flag, p3->open, p3->close, p3->minMap, p3->dps, p3->speed, etime);
				if (cur && __super::GetMap()->GetGround(cur->GetIndex())->HasFlag(p3->flag))
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
	std::shared_ptr<D> AStarNavigation<M, D>::BFS(float & sx, float & sy, int eindex, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap, int dps, int speed)
	{
		auto otop = open.top();
		int sindex = otop->GetIndex();
		auto v = GetOpensWithNear(sx, sy, eindex, dps, speed, close);
		open.pop();
		for (auto c : v)
		{
			if (c->GetIndex() == eindex)
			{
				c->SetLast(otop);
				return c;
			}
			AddOpen(open, otop, c, minMap);
			__super::AddClose(close, sindex, c->GetIndex());
		}
		if (open.empty())
			return nullptr;
		return open.top();
	}

	template<typename M, typename D>
	std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(float & sx, float & sy, int eindex, int dps, int speed, std::unordered_set<int> & close)
	{
		auto map = __super::GetMap();
		int sindex = map->GetIndex(sx, sy);
		int x = sx;
		int y = sy;
		int max = map->GetWidth() * map->GetHeight();
		std::vector<int> vec({ map->GetIndex(x + 1, y + 1), map->GetIndex(x + 1, y), map->GetIndex(x + 1, y - 1), map->GetIndex(x, y + 1), map->GetIndex(x, y - 1), map->GetIndex(x - 1, y + 1), map->GetIndex(x - 1, y), map->GetIndex(x - 1, y - 1) });
		std::vector<ptrD> ret;
		for (int index : vec)
		{
			if (index < 0 || index >= max || __super::IsInClose(close, sindex, index))
				continue;
			auto g = map->GetGround(index);
			if (g && g->GetHeight() >= 0)
			{
				auto d = new D();
				ret.push_back(ptrD(d));
				d->Init(index, __super::CalcuDistance(sx, sy, index, dps, speed), __super::ExpectDistance(index, eindex));
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
			__super::AddOpen(open, o);
		}
		return this;
	}

}