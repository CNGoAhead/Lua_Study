// Navigation.cpp: 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"

#include "./Navigation/Private/AStarNavigation.h"
#include "./Navigation/Private/Distance.h"
#include "./Navigation/Private/Map.h"
#include "./Navigation/Private/Ground.h"

AStarNavigation<Map<Ground>, Distance> navigation;

extern "C" __declspec(dllexport) void Init(int w, int h, int * heights, int len, int * flags, int flens) {
	auto map = std::shared_ptr<Map<Ground>>(new Map<Ground>());
	std::unordered_map<int, int> hs;
	std::unordered_map<int, short> fs;
	for (int i = 0; i < len * 3; i += 3)
		hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
	for (int i = 0; i < flens * 3; i += 3)
		fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
	map->Init(w, h, hs, fs);
	navigation.Init(map);
	return;
}

extern "C" __declspec(dllexport) void UpdateFlag(int * flags, int flens) {
	auto m = navigation.GetMap();
	std::unordered_map<int, short> fs;
	for (int i = 0; i < flens * 3; i += 3)
		fs[m->GetIndex(flags[i], flags[i + 1])] = flags[i + 2];
	m->UpdateFlag(fs);
}

extern "C" __declspec(dllexport) int Search(int * path, int sx, int sy, int ex, int ey, int dps, int speed) {
	auto p = navigation.Search(sx, sy, ex, ey, dps, speed);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int MultiSearch(int * path, int sx, int sy, int * epos, int elen, int dps, int speed) {
	std::vector<std::pair<int, int>> ends;
	for (int i = 0; i < elen * 2; i += 2)
		ends.push_back(std::pair<int, int>(epos[i], epos[i + 1]));
	auto p = navigation.MultiSearch(sx, sy, ends, dps, speed);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int FlagSearch(int * path, int sx, int sy, int flag, int dps, int speed) {
	auto p = navigation.FlagSearch(sx, sy, flag, dps, speed);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

int test = [&]() {

	std::vector<int> hs;
	std::vector<int> fs;

	int w = rand() % 51 + 50;
	int h = rand() % 51 + 50;
	for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++)
		{
			hs.push_back(x);
			hs.push_back(y);
			hs.push_back(max(rand() % 400 - 300, 0));
		}
	fs.push_back(rand() % w);
	fs.push_back(rand() % h);
	fs.push_back(1);
	Init(w, h, hs.data(), hs.size() / 3, fs.data(), fs.size() / 3);
	int path[10000] = {};
	Search(path, rand() % w, rand() % h, rand() % w, rand() % h, 1, 1);
	std::vector<int> ends;
	ends.push_back(rand() % w);
	ends.push_back(rand() % h);
	ends.push_back(rand() % w);
	ends.push_back(rand() % h);
	MultiSearch(path, rand() % w, rand() % h, ends.data(), ends.size() / 2, 1, 1);
	FlagSearch(path, rand() % w, rand() % h, 1, 1, 1);
	return 0;
}();
