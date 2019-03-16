#pragma once

#include <memory>
#include <unordered_map>

namespace NS_Navigation {

	template<typename G>
	class IMap
	{
	public:
		using ptrG = std::shared_ptr<G>;

		virtual IMap * Init(int w, int h, std::unordered_map<int, int> hight, std::unordered_map<int, unsigned short> flag) = 0;
		virtual IMap * UpdateHeight(const std::unordered_map<int, int> & difh) = 0;
		virtual IMap * UpdateFlag(const std::unordered_map<int, unsigned short> & difg) = 0;
		virtual IMap * AddHeight(const std::unordered_map<int, int> & difh) = 0;
		virtual IMap * AddFlag(const std::unordered_map<int, unsigned short> & difg) = 0;
		virtual IMap * SubHeight(const std::unordered_map<int, int> & difh) = 0;
		virtual IMap * SubFlag(const std::unordered_map<int, unsigned short> & difg) = 0;
		virtual IMap * AnalysisMap() = 0;
		virtual std::shared_ptr<G> GetGround(int index) = 0;
		virtual int GetWidth() const = 0;
		virtual int GetHeight() const = 0;
		virtual int GetIndex(int x, int y) const = 0;
		virtual int GetX(int index) const = 0;
		virtual int GetY(int index) const = 0;
	};

}