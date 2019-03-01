#include "Map.h"


template<typename G>
Map<G>::Map()
{

}

template<typename G>
Map<G>::~Map()
{

}

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
			auto ground = std::shared_ptr<IGround>(new G());
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
