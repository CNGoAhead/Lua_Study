#pragma once

#include "..\Public\IMap.h"
#include <memory>

class Map : public IMap
{
public:
	virtual IMap * Init(int w, int h, std::unordered_map<std::pair<int, int>, int> hight = std::unordered_map<std::pair<int, int>, int>(), std::unordered_map<std::pair<int, int>, int> flag = std::unordered_map<std::pair<int, int>, int>());
	virtual IMap * AnalysisMap();
	virtual IGround * GetGround(int index);
	virtual int GetWidth() const;
	virtual int GetHeight() const;
	virtual int GetIndex(int x, int y) const;
	virtual int GetX(int index) const;
	virtual int GetY(int index) const;

private:

	int _w;
	int _h;
	std::vector<std::shared_ptr<IGround>> _grounds;

};