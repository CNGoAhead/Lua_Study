#pragma once

class Ground
{
public:
    Ground();
    ~Ground();
    Ground * Init(int x, int y, int h = 0, int f = 0);
    int GetX() const { return _x; };
    int GetY() const { return _y; };
    int GetHeight() const { return _h; };
	int GetFlag() const { return _f; };
    Ground * SetX(int x) {
        _x = x;
        return this;
    }
    Ground * SetY(int y) {
        _y = y;
        return this;
    }
    Ground * SetHeight(int h) {
        _h = h;
        return this;
    }
	Ground * AddHeight(int h) {
		_h += h;
		return this;
	}
	Ground * RemoveHeight(int h) {
		_h -= h;
		return this;
	}
	Ground * SetFlag(int f) {
		_f = f;
		return this;
	}
	Ground * AddFlag(int f) {
		_f |= f;
		return this;
	}
	Ground * RemoveFlag(int f) {
		_f &= ~f;
		return this;
	}
private:
    int _x;
    int _y;
    int _h;
	int _f;
};

Ground::Ground()
{
    _x = 0;
    _y = 0;
    _h = 0;
	_f = 0;
}

Ground::~Ground()
{
}

inline Ground * Ground::Init(int x, int y, int h, int f)
{
    _x = x;
    _y = y;
    _h = h;
	_f = f;
    return this;
}
