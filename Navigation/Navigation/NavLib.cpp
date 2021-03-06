// Navigation.cpp: 定义 DLL 应用程序的导出函数。
//
#include "stdafx.h"
#include "NavLib.h"
#include "Navigation/ToLua_Navigation.h"

#ifdef DLL
#include <windows.h>

#include "./Navigation/Private/AStarNavigation.h"
#include "./Navigation/Private/Distance.h"
#include "./Navigation/Private/Map.h"
#include "./Navigation/Private/Ground.h"

using namespace NS_Navigation;
typedef typename AStarNavigation<Map<Ground>, Distance> Nav;

#ifdef TEST
Nav navigation;
#endif // TEST

#ifdef DEBUG
#include <iostream>
int TotalCount = 0;
int MaxTime = 0;
int MaxTime2 = 0;
int DiffTime = 0;
int GoodCount = 0;
int BadCount = 0;
int TotalTime = 0;
int TotalTime2 = 0;
bool G_bErrorPrint = false;
#endif // DEBUG

extern "C" __declspec(dllexport) Nav * Create() {
	return new Nav();
}

extern "C" __declspec(dllexport) void Delete(Nav * nav) {
	return delete nav;
}

extern "C" __declspec(dllexport) void Init(Nav * nav, int w, int h) {
	auto map = std::shared_ptr<Map<Ground>>(new Map<Ground>());
	map->Init(w, h);
	nav->Init(map);
	return;
}

extern "C" __declspec(dllexport) void UpdateHeight(Nav * nav, int * heights, int len) {
	std::unordered_map<int, int> hs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
	map->UpdateHeight(hs);
	return;
}

extern "C" __declspec(dllexport) void AddHeight(Nav * nav, int * heights, int len) {
	std::unordered_map<int, int> hs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
	map->AddHeight(hs);
	return;
}

extern "C" __declspec(dllexport) void SubHeight(Nav * nav, int * heights, int len) {
	std::unordered_map<int, int> hs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
	map->SubHeight(hs);
	return;
}

extern "C" __declspec(dllexport) void UpdateFlag(Nav * nav, int * flags, int len) {
	std::unordered_map<int, unsigned short> fs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
	map->UpdateFlag(fs);
	return;
}

extern "C" __declspec(dllexport) void AddFlag(Nav * nav, int * flags, int len) {
	std::unordered_map<int, unsigned short> fs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
	map->AddFlag(fs);
	return;
}

extern "C" __declspec(dllexport) void SubFlag(Nav * nav, int * flags, int len) {
	std::unordered_map<int, unsigned short> fs;
	auto map = nav->GetMap();
	int w = map->GetWidth();
	for (int i = 0; i < len * 3; i += 3)
		fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
	map->SubFlag(fs);
	return;
}

extern "C" __declspec(dllexport) int Search(Nav * nav, int * path, int sx, int sy, int ex, int ey, int dps, int speed, int duration) {
	auto p = nav->Search(sx, sy, ex, ey, dps, speed, duration);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int FlagSearch(Nav * nav, int * path, int sx, int sy, unsigned short flag, int dps, int speed, int duration) {
	auto p = nav->FlagSearch(sx, sy, flag, dps, speed, duration);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int MultiSearch(Nav * nav, int * path, int sx, int sy, int * ends, int len, int dps, int speed, int duration) {
	std::vector<std::pair<int, int>> es;
	for (int i = 0; i < len * 2; i += 2)
		es.push_back(std::pair<int, int>(ends[i], ends[i + 1]));
	auto p = nav->MultiSearch(sx, sy, es, dps, speed, duration);
	int l = p.size();
	for (int i = 0; i < l; i++)
		path[i] = p[i];
	return l;
}

extern "C" __declspec(dllexport) int ResumeSearch(Nav * nav, int * path, int resumeId, int duration) {
	auto p = nav->ResumeSearch(resumeId, duration);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

#ifdef TEST
extern "C" __declspec(dllexport) void Init(int w, int h, int * heights, int len, int * flags, int flens) {
	auto map = std::shared_ptr<Map<Ground>>(new Map<Ground>());
	std::unordered_map<int, int> hs;
	std::unordered_map<int, unsigned short> fs;
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
	std::unordered_map<int, unsigned short> fs;
	for (int i = 0; i < flens * 3; i += 3)
		fs[m->GetIndex(flags[i], flags[i + 1])] = flags[i + 2];
	m->UpdateFlag(fs);
}

extern "C" __declspec(dllexport) int Search(int * path, int sx, int sy, int ex, int ey, int dps, int speed, int duration = -1) {
#ifdef DEBUG
	int time = 0;
	int s = ::GetTickCount();
#endif // DEBUG

	auto p = navigation.Search(sx, sy, ex, ey, dps, speed, duration);

#ifdef DEBUG
	time = ::GetTickCount() - s;
	//std::cout << navigation.GetMap()->ToString(p) << std::endl;

	int time2 = 0;

	s = ::GetTickCount();
	//p = navigation.NormalSearch(sx, sy, ex, ey, dps, speed);
	time2 = ::GetTickCount() - s;

	//std::cout << navigation.GetMap()->ToString(p) << std::endl;
	GoodCount += time > time2 ? 1 : 0;
	BadCount += time < time2 ? 1 : 0;

	TotalTime += time;
	TotalTime2 += time2;
	std::cout << "Cost Time = " << time << ":" << time2 << std::endl;
	MaxTime = max(MaxTime, time);
	MaxTime2 = max(MaxTime2, time2);
	std::cout << "Max Time = " << MaxTime << ":" << MaxTime2 << std::endl;
	std::cout << "Total Time = " << TotalTime << ":" << TotalTime2 << std::endl;
	std::cout << "Total Count = " << ++TotalCount << std::endl;
	std::cout << "Average Time = " << TotalTime / (float)TotalCount << ":" << TotalTime2 / (float)TotalCount << std::endl;
	std::cout << "Good : Bad = " << GoodCount << ":" << BadCount << std::endl;
#endif // DEBUG


	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int MultiSearch(int * path, int sx, int sy, int * epos, int elen, int dps, int speed, int duration = -1) {
	std::vector<std::pair<int, int>> ends;
	for (int i = 0; i < elen * 2; i += 2)
		ends.push_back(std::pair<int, int>(epos[i], epos[i + 1]));
	auto p = navigation.MultiSearch(sx, sy, ends, dps, speed, duration);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

extern "C" __declspec(dllexport) int FlagSearch(int * path, int sx, int sy, unsigned short flag, int dps, int speed, int duration = -1) {
	auto p = navigation.FlagSearch(sx, sy, flag, dps, speed, duration);
	int len = p.size();
	for (int i = 0; i < len; i++)
		path[i] = p[i];
	return len;
}

int test = [&]() {
	struct Compare
	{
		bool operator()(const Distance & a, const Distance & b) {
			return a > b;
		}
	};
	std::priority_queue<Distance, std::vector<Distance>, Compare> q;
	q.push(*Distance().Init(-1, 0, 212));
	q.top();
	q.pop();
	q.push(*Distance().Init(0, 14, 206));
	q.push(*Distance().Init(1, 10, 202));
	q.push(*Distance().Init(2, 14, 198));
	q.push(*Distance().Init(3, 10, 216));
	q.push(*Distance().Init(4, 14, 226));
	q.push(*Distance().Init(5, 14, 218));

	while (!q.empty())
	{
		std::cout << q.top().GetIndex() << std::endl;
		q.pop();
	}

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
#endif // TEST

#endif // DLL
