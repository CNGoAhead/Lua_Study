#pragma once

#pragma comment(lib, "lua51.lib")

class lua_State;
namespace NS_Navigation {
	extern "C" void Lua_Register_Navigation(lua_State * L);
};