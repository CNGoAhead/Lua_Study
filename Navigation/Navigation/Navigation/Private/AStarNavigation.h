#pragma once

#include "Navigation.h"

template<typename M, typename D>
class AStarNavigation : public Navigation<M, D>
{
public:
	using ptrM = std::shared_ptr<M>;
	using ptrD = std::shared_ptr<D>;

	AStarNavigation() : Navigation<M, D>(){
	};
	~AStarNavigation() {
	};

	virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration);

	virtual std::vector<int> FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration);

	virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> ends, int dps, int speed, int duration);

	virtual std::vector<int> ResumeSearch(int searchId);

private:

	virtual std::shared_ptr<D> BFS(int sindex, int eindex, int dps, int speed, std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual std::shared_ptr<D> LFS(int sindex, int eindex, int dps, int speed, std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap);

	virtual std::vector<std::shared_ptr<D>> GetOpensWithIndex(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close);

};


template<typename M, typename D>
std::vector<int> AStarNavigation<M, D>::Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration)
{
	int sindex = this->GetMap()->GetIndex(sx, sy);
	int eindex = this->GetMap()->GetIndex(ex, ey);
	std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> open;
	std::unordered_set<int> close;
	std::unordered_map<int, int> minMap;
	auto d = std::shared_ptr<D>(new D());
	d->Init(sindex, 0, this->ExpectDistance(sindex, eindex));
	open.push(d);
	auto end = BFS(sindex, eindex, dps, speed, open, close, minMap);
	std::vector<int> path;
	while (end)
	{
		path.push_back(end->GetIndex());
		end = std::shared_ptr<D>(static_cast<D*>(end.get()));
		 end->GetLast();
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
std::vector<int> AStarNavigation<M, D>::MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> ends, int dps, int speed, int duration)
{
	return std::vector<int>();
}

template<typename M, typename D>
std::vector<int> AStarNavigation<M, D>::ResumeSearch(int searchId)
{
	return std::vector<int>();
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::BFS(int sindex, int eindex, int dps, int speed, std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto cur = LFS(sindex, eindex, dps, speed, open, close, minMap);
	sindex = cur->GetIndex();
	while (sindex != eindex)
	{
		auto o = GetOpensWithIndex(sindex, eindex, dps, speed, close);
		auto otop = open.top();
		open.pop();
		for (auto c : o)
		{
			if (c->GetIndex() == eindex)
				return c;
			*c += *otop;
			if (minMap[c->GetIndex()] == 0 || c->GetLeft() < minMap[c->GetIndex()])
			{
				minMap[c->GetIndex()] = c->GetLeft();
				this->AddOpen(open, c);
			}
			this->AddClose(close, sindex, c->GetIndex());
		}
		cur = open.top();
		if (*cur == *otop)
			cur = LFS(sindex, eindex, dps, speed, open, close, minMap);
		sindex = cur->GetIndex();
	}
	return cur;
}

template<typename M, typename D>
std::shared_ptr<D> AStarNavigation<M, D>::LFS(int sindex, int eindex, int dps, int speed, std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare> & open, std::unordered_set<int> & close, std::unordered_map<int, int> & minMap)
{
	auto v = GetOpensWithIndex(sindex, eindex, dps, speed, close);
	auto o = std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare>(v.begin(), v.end());
	auto otop = open.top();
	auto ntop = o.top();
	while (*otop == *ntop && !this->IsInClose(close, sindex, ntop->GetIndex()) && ntop->GetIndex() != eindex)
	{
		*ntop += *otop;
		if (minMap[ntop->GetIndex()] == 0 || ntop->GetLeft() < minMap[ntop->GetIndex()])
		{
			minMap[ntop->GetIndex()] = ntop->GetLeft();
			this->AddOpen(open, ntop);
		}
		this->AddClose(close, sindex, ntop->GetIndex());
		sindex = ntop->GetIndex();
		v = GetOpensWithIndex(sindex, eindex, dps, speed, close);
		o = std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Campare>(v.begin(), v.end());
		otop = open.top();
		ntop = o.top();
	}
	return ntop;
}

template<typename M, typename D>
std::vector<std::shared_ptr<D>> AStarNavigation<M, D>::GetOpensWithIndex(int sindex, int eindex, int dps, int speed, std::unordered_set<int> & close)
{
	int len = this->GetMap()->GetWidth() * this->GetMap()->GetHeight();
	std::vector<int> vec({ sindex + 1, sindex - 1, sindex + len , sindex - len, sindex + len - 1, sindex + len + 1, sindex - len - 1, sindex - len + 1 });
	std::vector<std::shared_ptr<D>> ret;
	for (int index : vec)
	{
		if (this->IsInClose(close, sindex, index))
			continue;
		auto g = this->GetMap()->GetGround(index);
		if (g && g->GetHeight() >= 0)
		{
			ret.push_back(std::shared_ptr<D>(new D()));
			(*ret.rbegin())->Init(index, this->CalcuDistance(sindex, index, dps, speed), this->ExpectDistance(index, eindex));
		}
	}
	return ret;
}
