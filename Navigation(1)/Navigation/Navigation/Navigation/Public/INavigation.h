#pragma once

#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <memory>
#include <algorithm>
#include <queue>
#include "IMap.h"
#include "IDistance.h"

class INavigation
{
public:
	virtual INavigation * Init(std::shared_ptr<IMap> map) = 0;

	virtual INavigation * AddOpen(std::priority_queue<std::shared_ptr<IDistance>>& open, std::shared_ptr<IDistance>& o) = 0;

	virtual INavigation * AddClose(std::unordered_set<long long>& close, int index1, int index2 = -1) = 0;

	virtual bool IsInClose(std::unordered_set<long long>& close, int index1, int index2 = -1) = 0;

	virtual int ExpectDistance(int index1, int index2) = 0;

	virtual int CalcuDistance(int index1, int index2, int dps, int speed) = 0;

	virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration = 0) = 0;

	virtual std::vector<int> FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration = 0) = 0;

	virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> ends, int dps, int speed, int duration = 0) = 0;

	virtual std::vector<int> ResumeSearch(int searchId) = 0;
};