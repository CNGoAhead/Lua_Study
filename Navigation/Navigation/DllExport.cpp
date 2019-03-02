// Navigation.cpp: 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"

#include "./Navigation/./Private/AStarNavigation.h"
#include "./Navigation/./Private/Distance.h"
#include "./Navigation/./Private/Map.h"
#include "./Navigation/./Private/Ground.h"

Ground g;

Map<Ground> m;

AStarNavigation<Map<Ground>, Distance> a;
