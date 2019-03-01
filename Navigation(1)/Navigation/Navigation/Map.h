#pragma once

#include <vector>
#include "Ground.h"
#include <sstream>

#include <iostream>

class Map
{
public:
    Map();
    ~Map();

    int GetIndex(Ground& ground) const;
    int GetIndex(Ground* ground) const;
    int GetIndex(int x, int y) const;

    Ground* GetGround(int index);
    int GetX(int index) const {
        return index % _width;
    };
    int GetY(int index) const {
        return index / _width;
    };

    int GetWidth() const { return _width; };
    int GetHeight() const { return _height; };

    Map & Init(int width, int height, std::vector<int> heights = std::vector<int>());

    std::string ToString(){
        std::stringstream ss;
        for (int y = 0; y < _height; y++)
        {
            for (int x = 0; x < _width; x++)
            {

                int index = GetIndex(x, y);
                auto g = GetGround(index);
                if (g->GetHeight() == 0)
                {
                    ss << "[ ]";
                }
                else
                {
                    ss << "[+]";
                }
            }
            ss << "\n";
        }
        return ss.str();
    };

private:
    int _width;
    int _height;
    std::vector<Ground> _grounds;
};

Map::Map()
{
}

Map::~Map()
{
}

inline int Map::GetIndex(Ground & ground) const
{
    int x = ground.GetX();
    int y = ground.GetY();
    return GetIndex(x, y);
}

inline int Map::GetIndex(Ground * ground) const
{
    int x = ground->GetX();
    int y = ground->GetY();
    return GetIndex(x, y);
}

inline int Map::GetIndex(int x, int y) const
{
    if (x >= 0 && y >= 0 && x < _width && y < _height)
        return x + y * _width;
    else
        return -1;
}

inline Ground* Map::GetGround(int index)
{
    if (index < _grounds.size())
        return &_grounds[index];
    else
        return nullptr;
}

inline Map & Map::Init(int width, int height, std::vector<int> heights)
{
    _width = width;
    _height = height;
    _grounds.resize(width * height);
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            int index = GetIndex(x, y);
            int h = 0;
            if (index < heights.size())
            {
                h = heights[index];
            }
            _grounds[index].Init(x, y, h);
        }
    }
    return *this;
}
