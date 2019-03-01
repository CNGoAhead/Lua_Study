#pragma once

#include "..\Public\IMap.h"
#include <memory>

template<typename G = IGround>
class Map : public IMap<G>
{
public:
	Map();
	~Map();

	static int GetIndex(int w, int x, int y);

	virtual IMap<G> * Init(int w, int h, std::unordered_map<int, int> height = std::unordered_map<int, int>(), std::unordered_map<int, int> flag = std::unordered_map<int, int>());
	virtual IMap<G> * AnalysisMap();
	virtual std::shared_ptr<G> GetGround(int index);
	virtual int GetWidth() const;
	virtual int GetHeight() const;
	virtual int GetIndex(int x, int y) const;
	virtual int GetX(int index) const;
	virtual int GetY(int index) const;

private:

	int _w;
	int _h;
	std::vector<std::shared_ptr<G>> _grounds;

};
