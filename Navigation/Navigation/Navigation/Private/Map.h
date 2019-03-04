#pragma once

#include "..\Public\IMap.h"
#include <memory>

template<typename G = IGround>
class Map : public IMap<G>
{
public:
	using ptrG = std::shared_ptr<G>;

	Map() : IMap<G>(){
	};
	~Map() {
	};

	static int GetIndex(int w, int x, int y);

	virtual IMap<G> * Init(int w, int h, std::unordered_map<int, int> height = std::unordered_map<int, int>(), std::unordered_map<int, int> flag = std::unordered_map<int, int>());
	virtual IMap<G> * AnalysisMap();
	virtual std::shared_ptr<G> & GetGround(int index);
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

template<typename G>
inline int Map<G>::GetIndex(int w, int x, int y)
{
	return x + y * w;
}

template<typename G>
inline IMap<G> * Map<G>::Init(int w, int h, std::unordered_map<int, int> height, std::unordered_map<int, int> flag)
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
			_grounds[index] = ground;
		}
	}
	return this;
}

template<typename G>
IMap<G> * Map<G>::AnalysisMap()
{
	return this;
}

// Ϊʲôһ��Map<G>::ptrG�ͱ��뱨��������
template<typename G>
inline std::shared_ptr<G> & Map<G>::GetGround(int index)
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