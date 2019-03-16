#pragma once

#include "..\Public\IMap.h"
#include <memory>
#include <string>
#include <sstream>

namespace NS_Navigation {

	template<typename G>
	class Map : public IMap<G>
	{
	public:
		using ptrG = std::shared_ptr<G>;

		Map() : IMap<G>() {
		};
		~Map() {
		};

		static int GetIndex(int w, int x, int y);

		std::string ToString(const std::vector<int> & path) const;

		virtual Map * Init(int w, int h, std::unordered_map<int, int> height = std::unordered_map<int, int>(), std::unordered_map<int, unsigned short> flag = std::unordered_map<int, unsigned short>());
		virtual Map * UpdateHeight(const std::unordered_map<int, int> & difh);
		virtual Map * UpdateFlag(const std::unordered_map<int, unsigned short> & difg);
		virtual Map * AddHeight(const std::unordered_map<int, int> & difh);
		virtual Map * AddFlag(const std::unordered_map<int, unsigned short> & difg);
		virtual Map * SubHeight(const std::unordered_map<int, int> & difh);
		virtual Map * SubFlag(const std::unordered_map<int, unsigned short> & difg);
		virtual Map * AnalysisMap();
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

	template<typename G /*= IGround*/>
	std::string Map<G>::ToString(const std::vector<int> & path) const
	{
		std::unordered_map<int, int> p;
		int c = 0;
		for (auto i : path)
			p[i] = ++c % 10;
		std::stringstream ss;
		for (int y = _h - 1; y >= 0; y--)
		{
			for (int x = _w - 1; x >= 0; x--)
			{
				int index = GetIndex(x, y);
				char l = '[', r = ']';
				if (_grounds[index]->GetHeight() > 0)
					l = '{', r = '}';
				if (p.find(index) != p.end())
					ss << l << p[index] << r;
				else
					ss << l << " " << r;
			}
			ss << std::endl;
		}
		return ss.str();
	}

	template<typename G>
	inline Map<G> * Map<G>::SubFlag(const std::unordered_map<int, unsigned short> & difg)
	{
		for (auto p : difg)
			_grounds[p.first]->SubFlag(p.second);
		return this;
	}

	template<typename G>
	inline Map<G> * Map<G>::AddFlag(const std::unordered_map<int, unsigned short> & difg)
	{
		for (auto p : difg)
			_grounds[p.first]->AddFlag(p.second);
		return this;
	}

	template<typename G>
	inline Map<G> * Map<G>::AddHeight(const std::unordered_map<int, int> & difh)
	{
		for (auto p : difh)
			_grounds[p.first]->AddHeight(p.second);
		return this;
	}

	template<typename G>
	inline Map<G> * Map<G>::SubHeight(const std::unordered_map<int, int> & difh)
	{
		for (auto p : difh)
			_grounds[p.first]->SubHeight(p.second);
		return this;
	}

	template<typename G>
	inline Map<G> * Map<G>::UpdateFlag(const std::unordered_map<int, unsigned short> & difg)
	{
		for (auto p : difg)
			_grounds[p.first]->SetFlag(p.second);
		return this;
	}

	template<typename G>
	inline Map<G> * Map<G>::UpdateHeight(const std::unordered_map<int, int> & difh)
	{
		for (auto p : difh)
			_grounds[p.first]->SetHeight(p.second);
		return this;
	}

	template<typename G>
	inline int Map<G>::GetIndex(int w, int x, int y)
	{
		return x + y * w;
	}

	template<typename G>
	inline Map<G> * Map<G>::Init(int w, int h, std::unordered_map<int, int> height, std::unordered_map<int, unsigned short> flag)
	{
		_w = w;
		_h = h;
		_grounds.reserve(_w * _h);
		for (int y = 0; y < _h; y++)
		{
			for (int x = 0; x < _w; x++)
			{
				auto ground = std::shared_ptr<G>(new G());
				int index = GetIndex(x, y);
				ground->Init(x, y, height[index], flag[index]);
				_grounds.push_back(ground);
			}
		}
		return this;
	}

	template<typename G>
	Map<G> * Map<G>::AnalysisMap()
	{
		return this;
	}

	// 为什么一用Map<G>::ptrG就编译报错？？？
	template<typename G>
	inline std::shared_ptr<G> Map<G>::GetGround(int index)
	{
		return _grounds[index];
	}

	template<typename G>
	inline int Map<G>::GetWidth() const
	{
		return _w;
	}

	template<typename G>
	inline int Map<G>::GetHeight() const
	{
		return _h;
	}

	template<typename G>
	inline int Map<G>::GetIndex(int x, int y) const
	{
		return x + y * _w;
	}

	template<typename G>
	inline int Map<G>::GetX(int index) const
	{
		return index % _w;
	}

	template<typename G>
	inline int Map<G>::GetY(int index) const
	{
		return index / _w;
	}

}