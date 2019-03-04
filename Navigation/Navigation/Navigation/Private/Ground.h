#pragma once

#include "../Public/IGround.h"

class Ground : public IGround
{
public:
	Ground(): IGround(), _x(0), _y(0), _h(0), _f(0) {
	};
	~Ground() {
	};

	virtual IGround * Init(int x, int y, int h, short f);
	virtual int GetX() const;
	virtual int GetY() const;
	virtual int GetHeight() const;
	virtual short GetFlag() const;
	virtual IGround * SetX(int x);
	virtual IGround * SetY(int y);
	virtual IGround * SetHeight(int h);
	virtual IGround * AddHeight(int h);
	virtual IGround * SubHeight(int h);
	virtual IGround * SetFlag(short f);
	virtual IGround * AddFlag(short f);
	virtual IGround * SubFlag(short f);
	virtual bool HasFlag(short f);

private:
	int _x;
	int _y;
	int _h;
	short _f;
};

inline IGround * Ground::Init(int x, int y, int h, short f)
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

inline short Ground::GetFlag() const
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

inline IGround * Ground::SubHeight(int h)
{
	_h -= h;
	return this;
}

inline IGround * Ground::SetFlag(short f)
{
	_f = f;
	return this;
}

inline IGround * Ground::AddFlag(short f)
{
	_f |= f;
	return this;
}

inline IGround * Ground::SubFlag(short f)
{
	_f &= ~f;
	return this;
}

inline bool Ground::HasFlag(short f)
{
	return _f & f;
}
