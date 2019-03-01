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
	virtual IGround * SetFlag(int f);

private:
	int _x;
	int _y;
	int _h;
	int _f;
};
