#pragma once

#include "Navigation.h"

template<typename M, typename D>
class AStarNavigation : public Navigation<M, D>
{
public:
	using ptrM = std::shared_ptr<M>;
	using ptrD = std::shared_ptr<D>;
	typedef Navigation<M, D>::Compare Compare;

	AStarNavigation() : Navigation<M, D>(){
	};
	~AStarNavigation() {
	};

	virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration = -1);

	virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration = -1);

	virtual std::vector<int> FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration = -1);

	virtual std::vector<int> ResumeSearch(int searchId);

private:

	virtual ptrD BFS(int sindex, int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual ptrD LFS(int sindex, int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual std::vector<ptrD> GetOpensWithNear(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close);

	virtual std::vector<ptrD> GetOpensWithDir(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close);

	virtual ptrD BFS(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual ptrD LFS(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual std::vector<ptrD> GetOpensWithNear(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close);

	virtual std::vector<ptrD> GetOpensWithDir(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close);

	virtual AStarNavigation<M, D> * AddOpen(std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, ptrD & o, std::unordered_map<int, int> & minMap);

	virtual ptrD BFS(int sindex, short flag, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual std::vector<ptrD> GetOpensWithNear(int sindex, int dps, int speed, std::unordered_set<int> & close);

	virtual int ExpectDistance(int index1, std::unordered_set<int> index2s);

};

template<typename M, typename D>
std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, int dps, int speed, std::unordered_set<int> & close)
{
	int len = Navigation<M, D>::GetMap()->GetWidth() * Navigation<M, D>::GetMap()->GetHeight();
	std::vector<int> vec({ sindex + 1, sindex - 1, sindex + len , sindex - len, sindex + len - 1, sindex + len + 1, sindex - len - 1, sindex - len + 1 });
	std::vector<ptrD> ret;
	for (int index : vec)
	{
		if (Navigation<M, D>::IsInClose(close, sindex, index))
			continue;
		auto g = Navigation<M, D>::GetMap()->GetGround(index);
		if (g && g->GetHeight() >= 0)
		{
			ret.push_back(ptrD(new D()));
			(*ret.rbegin())->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), 0);
		}
	}
	return ret;
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::BFS(int sindex, short flag, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	auto v = GetOpensWithNear(sindex, dps, speed, close);
	open.pop();
	for (auto c : v)
	{
		if (Navigation<M, D>::GetMap()->GetGround(c->GetIndex())->HasFlag(flag))
			return c;
		AddOpen(open, c, minMap);
		Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
	}
	return open.top();
}

template<typename M, typename D>
int AStarNavigation<M, D>::ExpectDistance(int index1, std::unordered_set<int> index2s)
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
			ret.push_back(ptrD(new D()));
			(*ret.rbegin())->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), ExpectDistance(index, eindexs));
		}
	}
	return ret;
}

template<typename M, typename D>
std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::unordered_set<int> & close)
{
	int len = Navigation<M, D>::GetMap()->GetWidth() * Navigation<M, D>::GetMap()->GetHeight();
	std::vector<int> vec({ sindex + 1, sindex - 1, sindex + len , sindex - len, sindex + len - 1, sindex + len + 1, sindex - len - 1, sindex - len + 1 });
	std::vector<ptrD> ret;
	for (int index : vec)
	{
		if (Navigation<M, D>::IsInClose(close, sindex, index))
			continue;
		auto g = Navigation<M, D>::GetMap()->GetGround(index);
		if (g && g->GetHeight() >= 0)
		{
			ret.push_back(ptrD(new D()));
			(*ret.rbegin())->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), ExpectDistance(index, eindexs));
		}
	}
	return ret;
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::LFS(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	auto v = GetOpensWithDir(sindex, eindexs, dps, speed, close);
	for (auto c : v)
	{
		if (eindexs.find(c->GetIndex()) != eindexs.end())
			return c;
		AddOpen(open, c, minMap);
		Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
	}
	return open.top();
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::BFS(int sindex, std::unordered_set<int> eindexs, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	auto v = GetOpensWithNear(sindex, eindexs, dps, speed, close);
	open.pop();
	for (auto c : v)
	{
		if (eindexs.find(c->GetIndex()) != eindexs.end())
			return c;
		AddOpen(open, c, minMap);
		Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
	}
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
			ret.push_back(ptrD(new D()));
			(*ret.rbegin())->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), Navigation<M, D>::ExpectDistance(index, eindex));
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

	auto ocur = open.top();
	auto cur = LFS(sindex, eindex, dps, speed, open, close, minMap);
	sindex = cur->GetIndex();
	while (sindex != eindex && (etime <= 0 || ::GetTickCount() > etime))
	{
		if (cur != d && cur != ocur && *cur == *(cur->GetLast()))
		{
			ocur = cur;
			cur = LFS(sindex, eindex, dps, speed, open, close, minMap);
		}
		else
		{
			ocur = cur;
			cur = BFS(sindex, eindex, dps, speed, open, close, minMap);
		}
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
	return path;
}

template<typename M, typename D>
std::vector<int> AStarNavigation<M, D>::FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration)
{
	return std::vector<int>();
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

	int etime = ::GetTickCount() + (duration > 0 ? duration : INT_MAX);

	auto ocur = open.top();
	auto cur = LFS(sindex, eindexs, dps, speed, open, close, minMap);
	sindex = cur->GetIndex();
	while (eindexs.find(sindex) != eindexs.end() && ::GetTickCount() > etime)
	{
		if (cur != d && cur != ocur && *cur == *(cur->GetLast()))
		{
			ocur = cur;
			cur = LFS(sindex, eindexs, dps, speed, open, close, minMap);
		}
		else
		{
			ocur = cur;
			cur = BFS(sindex, eindexs, dps, speed, open, close, minMap);
		}
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
	return path;
}

template<typename M, typename D>
std::vector<int> AStarNavigation<M, D>::ResumeSearch(int searchId)
{
	return std::vector<int>();
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::BFS(int sindex, int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	auto v = GetOpensWithNear(sindex, eindex, dps, speed, close);
	open.pop();
	for (auto c : v)
	{
		if (c->GetIndex() == eindex)
		{
			c->SetLast(otop);
			return c;
		}
		AddOpen(open, c, minMap);
		Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
	}
	return open.top();
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::LFS(int sindex, int eindex, int dps, int speed, std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	auto v = GetOpensWithDir(sindex, eindex, dps, speed, close);
	for (auto c : v)
	{
		if (c->GetIndex() == eindex)
		{
			c->SetLast(otop);
			return c;
		}
		AddOpen(open, c, minMap);
		Navigation<M, D>::AddClose(close, sindex, c->GetIndex());
	}
	return open.top();
}

template<typename M, typename D>
std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithNear(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close)
{
	int len = Navigation<M, D>::GetMap()->GetWidth();
	int max = Navigation<M, D>::GetMap()->GetWidth() * Navigation<M, D>::GetMap()->GetHeight();
	std::vector<int> vec({ sindex + 1, sindex - 1, sindex + len , sindex - len, sindex + len - 1, sindex + len + 1, sindex - len - 1, sindex - len + 1 });
	std::vector<ptrD> ret;
	for (int index : vec)
	{
		if (index < 0 || index >= max || Navigation<M, D>::IsInClose(close, sindex, index))
			continue;
		auto g = Navigation<M, D>::GetMap()->GetGround(index);
		if (g && g->GetHeight() >= 0)
		{
			ret.push_back(ptrD(new D()));
			(*ret.rbegin())->Init(index, Navigation<M, D>::CalcuDistance(sindex, index, dps, speed), Navigation<M, D>::ExpectDistance(index, eindex));
		}
	}
	return ret;
}

template<typename M, typename D>
AStarNavigation<M, D> * AStarNavigation<M, D>::AddOpen(std::priority_queue<ptrD, std::vector<ptrD>, Compare> & open, ptrD & o, std::unordered_map<int, int> & minMap)
{
	auto otop = open.top();
	if (minMap[o->GetIndex()] == 0 || o->GetLeft() < minMap[o->GetIndex()])
	{
		*o += *otop;
		o->SetLast(otop);
		minMap[o->GetIndex()] = o->GetLeft();
		Navigation<M, D>::AddOpen(open, o);
	}
	return this;
}