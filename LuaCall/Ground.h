#pragma once

class Ground
{
public:
    Ground();
    ~Ground();
    Ground& Init(int x, int y, int height);
    int GetX() const { return _x; };
    int GetY() const { return _y; };
    int GetHeight() const { return _height; };
    Ground& SetX(int x) {
        _x = x;
        return *this;
    }
    Ground& SetY(int y) {
        _y = y;
        return *this;
    }
    Ground& SetHeight(int height) {
        _height = height;
        return *this;
    }
private:
    int _x;
    int _y;
    int _height;
};

Ground::Ground()
{
    _x = 0;
    _y = 0;
    _height = 0;
}

Ground::~Ground()
{
}

inline Ground & Ground::Init(int x, int y, int height)
{
    _x = x;
    _y = y;
    _height = height;
    return *this;
}
