#pragma once

class IGround
{
public:
	virtual IGround * Init(int x, int y, int h, short f) = 0;
	virtual int GetX() const = 0;
	virtual int GetY() const = 0;
	virtual int GetHeight() const = 0;
	virtual short GetFlag() const = 0;
	virtual IGround * SetX(int x) = 0;
	virtual IGround * SetY(int y) = 0;
	virtual IGround * SetHeight(int h) = 0;
	virtual IGround * AddHeight(int h) = 0;
	virtual IGround * SubHeight(int h) = 0;
	virtual IGround * SetFlag(short f) = 0;
	virtual IGround * AddFlag(short f) = 0;
	virtual IGround * SubFlag(short f) = 0;
	virtual bool HasFlag(short f) = 0;
};

