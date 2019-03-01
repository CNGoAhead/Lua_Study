#pragma once

#include "..\Public\INavigation.h"

class Navigation : public INavigation
{
public:
	Navigation();
	virtual ~Navigation();

	virtual INavigation * Init(std::shared_ptr<IMap> map);

	virtual INavigation * AddOpen(std::priority_queue<std::shared_ptr<IDistance>>& open, std::shared_ptr<IDistance>& o);

	virtual INavigation * AddClose(std::unordered_set<long long>& close, int index1, int index2 = -1);

	virtual bool IsInClose(std::unordered_set<long long>& close, int index1, int index2 = -1);

	virtual int ExpectDistance(int index1, int index2);

	virtual int CalcuDistance(int index1, int index2, int dps, int speed);

	virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration) = 0;

	virtual std::vector<int> FlagSearch(int sx, int sy, int flag, int dps, int speed, int duration) = 0;

	virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> ends, int dps, int speed, int duration) = 0;

	virtual std::vector<int> ResumeSearch(int searchId) = 0;

private:

	std::shared_ptr<IMap> _map;

};
