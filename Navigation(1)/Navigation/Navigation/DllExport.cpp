// Navigation.cpp: 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include <iostream>
#include "Map.h"
#include "Navigation.h"
#include <memory>

Navigation nav;

int TotalCount = 0;
int MaxTime = 0;
int MaxTime2 = 0;
int GoodCount = 0;
int BadCount = 0;
int TimeCount = 0;
int ErrorCount = 0;
int TotalTime = 0;
bool G_bErrorPrint = false;

extern "C" __declspec(dllexport) void Init(int width, int height, int* heights) {
    auto map = std::shared_ptr<Map>(new Map());
    std::vector<int> h;
    h.assign(heights, heights + width * height - 1);
    map->Init(width, height, h);
    nav.Init(map);
    return;
}

extern "C" __declspec(dllexport) void Clear() {
    nav.Clear();
    return;
}

extern "C" __declspec(dllexport) int Search(int* path, int sx, int sy, int ex, int ey, int dps, int speed) {
    if (nav.IsInited())
    {
        int time1 = 0;
        int time2 = 0;
        int walk1 = 0;
        int walk2 = 0;
        int s = ::GetTickCount();
        auto result = nav.Search2(sx, sy, ex, ey, dps, speed);
        time1 = ::GetTickCount() - s;
        walk1 = result.dis.walk;
        std::cout << "cost time = " << time1 << std::endl;
        std::cout << "walk = " << walk1 << std::endl;
        auto p = result.path;
        //std::cout << nav.ToString(p) << std::endl;

        //s = ::GetTickCount();
        //result = nav.Search(sx, sy, ex, ey, dps, speed);
        //time2 = ::GetTickCount() - s;
        //walk2 = result.dis.walk;
        //std::cout << "cost time = " << time2 << std::endl;
        //std::cout << "walk = " << walk2 << std::endl;
        //p = result.path;
        //std::cout << nav.ToString(p) << std::endl;

        //std::cout << (time1 > time2 ? "Good" : (time1 == time2 ? "NoUse" : "Bad")) << std::endl;

        //if (time1 > time2)
        //    GoodCount++;
        //else if (time1 < time2)
        //    BadCount++;

        //TimeCount += time2 - time1;

        //std::cout << "Good : Bad = " << GoodCount << " : " << BadCount << std::endl;

        //std::cout << "Diff time = " << TimeCount << std::endl;

        //ErrorCount += walk1 < walk2 ? 1 : 0;

        //std::cout << "Error time = " << ErrorCount << std::endl;

		MaxTime = max(time1, MaxTime);
		//MaxTime2 = max(time2, MaxTime2);

		TotalTime += time1;
		std::cout << "Max Time = " << MaxTime << " : " << MaxTime2 << std::endl;

		std::cout << "Total Time = " << TotalTime << " : " << MaxTime2 << std::endl;

		TotalCount++;
		std::cout << "Total Count = " << TotalCount << std::endl;

		std::cout << "Average Time = " << TotalTime / (float)TotalCount << std::endl;

        //G_bErrorPrint = walk1< walk2;
		if (G_bErrorPrint)
		{
			result = nav.Search(sx, sy, ex, ey, dps, speed);
			G_bErrorPrint = false;
		}

        int len = p.size();
        for (int i = 0; i < len; i++)
        {
            path[i] = p[i];
        }
        return len;
    }
    return 0;
}