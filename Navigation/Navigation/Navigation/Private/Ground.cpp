#include "Ground.h"

Ground::Ground():_x(0),_y(0),_h(0),_f(0){
}
Ground::~Ground() {
}

inline IGround * Ground::Init(int x, int y, int h, int f)
{
	_x = x;
	_y = y;
	_h = h;
	_f = f;
	return this;
}

inline int Ground::GetX() const
{
	return _x;
}

inline int Ground::GetY() const
{
	return _y;
}

inline int Ground::GetHeight() const
{
	return _h;
}

inline int Ground::GetFlag() const
{
	return _f;
}

inline IGround * Ground::SetX(int x)
{
	_x = x;
	return this;
}

inline IGround * Ground::SetY(int y)
{
	_y = y;
	return this;
}

inline IGround * Ground::SetHeight(int h)
{
	_h = h;
	return this;
}

inline IGround * Ground::AddHeight(int h)
{
	_h += h;
	return this;
}

IGround * Ground::SubHeight(int h)
{
	_h -= h;
	return this;
}

inline IGround * Ground::SetFlag(int f)
{
	_f = f;
	return this;
}

inline IGround * Ground::AddFlag(int f)
{
	_f |= f;
	return this;
}

inline IGround * Ground::SubFlag(int f)
{
	_f &= ~f;
	return this;
}

inline bool Ground::HasFlag(int f)
{
	return _f & f;
}

