#pragma once

#include "../Public/IGround.h"

class Ground : public IGround
{
public:
	Ground();
	~Ground();

	virtual IGround * Init(int x, int y, int h, int f);
	virtual int GetX() const;
	virtual int GetY() const;
	virtual int GetHeight() const;
	virtual int GetFlag() const;
	virtual IGround * SetX(int x);
	virtual IGround * SetY(int y);
	virtual IGround * SetHeight(int h);
	virtual IGround * AddHeight(int h);
	virtual IGround * SubHeight(int h);
	virtual IGround * SetFlag(int f);
	virtual IGround * AddFlag(int f);
	virtual IGround * SubFlag(int f);
	virtual bool HasFlag(int f);

private:
	int _x;
	int _y;
	int _h;
	int _f;
};
