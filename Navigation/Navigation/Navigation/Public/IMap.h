#pragma once

#include <memory>
#include <unordered_map>
#include "IGround.h"

template<typename G = IGround>
class IMap
{
public:
	virtual IMap * Init(int w, int h, std::unordered_map<int, int> hight, std::unordered_map<int, int> flag) = 0;
	virtual IMap * AnalysisMap() = 0;
	virtual std::shared_ptr<G> GetGround(int index) = 0;
	virtual int GetWidth() const = 0;
	virtual int GetHeight() const = 0;
	virtual int GetIndex(int x, int y) const = 0;
	virtual int GetX(int index) const = 0;
	virtual int GetY(int index) const = 0;
};