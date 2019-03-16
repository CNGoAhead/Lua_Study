#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "../lua/tolua/tolua++.h"
#ifdef __cplusplus
}
#endif

#include <iostream>

#include "../lua/tolua/tolua_fix.h"

#include "./Private/AStarNavigation.h"
#include "./Private/Distance.h"
#include "./Private/Map.h"
#include "./Private/Ground.h"

int costTime = 0;

namespace NS_Navigation {

	typedef typename AStarNavigation<Map<Ground>, Distance> Nav;

	Nav * Create() {
		return new Nav();
	}

	void Delete(Nav * nav) {
		return delete nav;
	}

	void Init(Nav * nav, int w, int h) {
		auto map = std::shared_ptr<Map<Ground>>(new Map<Ground>());
		map->Init(w, h);
		nav->Init(map);
		return;
	}

	void UpdateHeight(Nav * nav, std::vector<int> & heights, int len) {
		std::unordered_map<int, int> hs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
		map->UpdateHeight(hs);
		return;
	}

	void AddHeight(Nav * nav, std::vector<int> & heights, int len) {
		std::unordered_map<int, int> hs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
		map->AddHeight(hs);
		return;
	}

	void SubHeight(Nav * nav, std::vector<int> & heights, int len) {
		std::unordered_map<int, int> hs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			hs[Map<Ground>::GetIndex(w, heights[i], heights[i + 1])] = heights[i + 2];
		map->SubHeight(hs);
		return;
	}

	void UpdateFlag(Nav * nav, std::vector<unsigned short> & flags, int len) {
		std::unordered_map<int, unsigned short> fs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
		map->UpdateFlag(fs);
		return;
	}

	void AddFlag(Nav * nav, std::vector<unsigned short> & flags, int len) {
		std::unordered_map<int, unsigned short> fs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
		map->AddFlag(fs);
		return;
	}

	void SubFlag(Nav * nav, std::vector<unsigned short> & flags, int len) {
		std::unordered_map<int, unsigned short> fs;
		auto map = nav->GetMap();
		int w = map->GetWidth();
		for (int i = 0; i < len * 3; i += 3)
			fs[Map<Ground>::GetIndex(w, flags[i], flags[i + 1])] = flags[i + 2];
		map->SubFlag(fs);
		return;
	}

	std::vector<int> Search(Nav * nav, int sx, int sy, int ex, int ey, int dps, int speed, int duration) {
		return nav->Search(sx, sy, ex, ey, dps, speed, duration);
	}

	std::vector<int> FlagSearch(Nav * nav, int sx, int sy, unsigned short flag, int dps, int speed, int duration) {
		return nav->FlagSearch(sx, sy, flag, dps, speed, duration);
	}

	std::vector<int> MultiSearch(Nav * nav, int sx, int sy, std::vector<int> & ends, int dps, int speed, int duration) {
		std::vector<std::pair<int, int>> es;
		for (int i = 0; i < ends.size(); i += 2)
			es.push_back(std::pair<int, int>(ends[i], ends[i + 1]));
		return nav->MultiSearch(sx, sy, es, dps, speed, duration);
	}

	std::vector<int> ResumeSearch(Nav * nav, int resumeId, int duration) {
		return nav->ResumeSearch(resumeId, duration);
	}

	int Lua_Create(lua_State * L) {
		object_to_luaval<Nav>(L, "Navigation", Create());
		return 1;
	}

	int Lua_Delete(lua_State * L) {
		delete tolua_tousertype(L, 1, 0);
		return 0;
	}

	int Lua_Init(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		int w = 0;
		int h = 0;
		luaval_to_int32(L, 2, &w);
		luaval_to_int32(L, 3, &h);
		Init(nav, w, h);
		return 0;
	}

	int Lua_UpdateHeight(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<int> vec;
		int len = 0;
		luaval_to_std_vector_int(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		UpdateHeight(nav, vec, len);
		return 0;
	}

	int Lua_AddHeight(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<int> vec;
		int len = 0;
		luaval_to_std_vector_int(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		AddHeight(nav, vec, len);
		return 0;
	}

	int Lua_SubHeight(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<int> vec;
		int len = 0;
		luaval_to_std_vector_int(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		SubHeight(nav, vec, len);
		return 0;
	}

	int Lua_UpdateFlag(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<unsigned short> vec;
		int len = 0;
		luaval_to_std_vector_ushort(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		UpdateFlag(nav, vec, len);
		return 0;
	}

	int Lua_AddFlag(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<unsigned short> vec;
		int len = 0;
		luaval_to_std_vector_ushort(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		AddFlag(nav, vec, len);
		return 0;
	}

	int Lua_SubFlag(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		std::vector<unsigned short> vec;
		int len = 0;
		luaval_to_std_vector_ushort(L, 2, &vec);
		luaval_to_int32(L, 3, &len);
		SubFlag(nav, vec, len);
		return 0;
	}

	int Lua_Search(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		int sx, sy, ex, ey, dps, speed, duration = -1;
		luaval_to_int32(L, 2, &sx);
		luaval_to_int32(L, 3, &sy);
		luaval_to_int32(L, 4, &ex);
		luaval_to_int32(L, 5, &ey);
		luaval_to_int32(L, 6, &dps);
		luaval_to_int32(L, 7, &speed);
		if (lua_gettop(L) == 8)
			luaval_to_int32(L, 8, &duration);
		auto path = Search(nav, sx, sy, ex, ey, dps, speed, duration);
		int len = 0;
		for (; len < path.size(); len++)
			tolua_pushnumber(L, path[len]);
		return len;
	}

	int Lua_FlagSearch(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		int sx, sy, dps, speed, duration = -1;
		unsigned short flag;
		luaval_to_int32(L, 2, &sx);
		luaval_to_int32(L, 3, &sy);
		luaval_to_ushort(L, 4, &flag);
		luaval_to_int32(L, 5, &dps);
		luaval_to_int32(L, 6, &speed);
		if (lua_gettop(L) == 7)
			luaval_to_int32(L, 7, &duration);
		auto path = FlagSearch(nav, sx, sy, flag, dps, speed, duration);
		int len = 0;
		for (; len < path.size(); len++)
			tolua_pushnumber(L, path[len]);
		return len;
	}

	int Lua_MultiSearch(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		int sx, sy, dps, speed, duration = -1;
		std::vector<int> ends;
		luaval_to_int32(L, 2, &sx);
		luaval_to_int32(L, 3, &sy);
		luaval_to_std_vector_int(L, 4, &ends);
		luaval_to_int32(L, 5, &dps);
		luaval_to_int32(L, 6, &speed);
		if (lua_gettop(L) == 7)
			luaval_to_int32(L, 7, &duration);
		auto path = MultiSearch(nav, sx, sy, ends, dps, speed, duration);
		int len = 0;
		for (; len < path.size(); len++)
			tolua_pushnumber(L, path[len]);
		return len;
	}

	int Lua_ResumeSearch(lua_State * L) {
		auto nav = (Nav*)tolua_tousertype(L, 1, 0);
		int id, duration = -1;
		luaval_to_int32(L, 2, &id);
		if (lua_gettop(L) == 3)
			luaval_to_int32(L, 3, &duration);
		auto path = ResumeSearch(nav, id, duration);
		int len = 0;
		for (; len < path.size(); len++)
			tolua_pushnumber(L, path[len]);
		return len;
	}

	void Lua_Register_Navigation(lua_State * L) {
		lua_getglobal(L, "_G");
		if (lua_istable(L, -1))
		{
			tolua_open(L);
			tolua_module(L, "Navigation", 0);
			tolua_usertype(L, "Navigation");
			tolua_cclass(L, "Navigation", "Navigation", "", nullptr);
			tolua_beginmodule(L, "Navigation");
			tolua_function(L, "Create", Lua_Create);
			tolua_function(L, "Delete", Lua_Delete);
			tolua_function(L, "Init", Lua_Init);
			tolua_function(L, "UpdateHeight", Lua_UpdateHeight);
			tolua_function(L, "AddHeight", Lua_AddHeight);
			tolua_function(L, "SubHeight", Lua_SubHeight);
			tolua_function(L, "UpdateFlag", Lua_UpdateFlag);
			tolua_function(L, "AddFlag", Lua_AddFlag);
			tolua_function(L, "SubFlag", Lua_SubFlag);
			tolua_function(L, "Search", Lua_Search);
			tolua_function(L, "FlagSearch", Lua_FlagSearch);
			tolua_function(L, "MultiSearch", Lua_MultiSearch);
			tolua_function(L, "ResumeSearch", Lua_ResumeSearch);
			tolua_endmodule(L);
			std::string typeName = typeid(Nav).name();
			g_luaType[typeName] = "Navigation";
			g_typeCast["Navigation"] = "Navigation";
		}
		lua_pop(L, 1);

		return;
	}

}