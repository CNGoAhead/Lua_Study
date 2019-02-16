#pragma once

#include "stdafx.h"
#include "Ground.h"
#include "Map.h"
#include "BinHeap.h"
#include <unordered_map>
#include <map>
#include <unordered_set>
#include <sstream>
#include <memory>

extern bool G_bErrorPrint;

class Navigation
{
public:
    Navigation();
    ~Navigation();

    class Distance
    {
    public:
        bool operator==(const Distance& b) const {
            return walk + left == b.walk + b.left;
        }
        bool operator<(const Distance& b) const {
            return walk + left < b.left + b.walk;
        }
        bool operator>(const Distance& b) const {
            return walk + left > b.left + b.walk;
        }
        Distance& operator+=(const Distance& b) {
            walk += b.walk;
            left = left;
            return *this;
        }
        Distance operator+(const Distance& b) const {
            Distance d(0, 0);
            d.walk = walk + b.walk;
            d.left = b.left;
            return d;
        }
        Distance()
        {
            walk = 0;
            left = 0;
        }
        Distance(int w, int l)
        {
            walk = w;
            left = l;
        }
        Distance(const Distance& a)
        {
            walk = a.walk;
            left = a.left;
        }
        std::string ToString()
        {
            std::stringstream ss;
            ss << walk + left << "=" << walk << "+" << left;
            return ss.str();
        }
        int walk = 0;
        int left = 0;
    };

    class SearchResult
    {
    public:
        SearchResult(bool result, Distance d, std::list<int>& path, std::unordered_set<int>& close) {
            this->result = result;
            this->dis = d;
            this->path.assign(path.begin(), path.end());
            this->close.insert(close.begin(), close.end());
        };

        SearchResult(bool result, Distance d, std::list<int>&& path, std::unordered_set<int>& close) {
            this->result = result;
            this->dis = d;
            this->path.assign(path.begin(), path.end());
            this->close.insert(close.begin(), close.end());
        };

        bool result;
        Navigation::Distance dis;
        std::vector<int> path;
        std::unordered_set<int> close;
    };

    class OpenNode
    {
    public:
        OpenNode(int index, std::shared_ptr<OpenNode> last = std::shared_ptr<OpenNode>(nullptr), std::shared_ptr<OpenNode> next = std::shared_ptr<OpenNode>(nullptr)) {
            this->index = index;
            this->last = last;
            this->next = next;
        }

        //bool operator<(const OpenNode& b) const {
        //    return false;
        //}

        bool operator==(const OpenNode& b) const {
            if (b.last && last)
                return index == b.index && b.last == last;
            else if (!b.last && !last)
                return index == b.index;
            else
                return false;
        }

        int index;
        std::shared_ptr<OpenNode> last;
        std::shared_ptr<OpenNode> next;
    };

    SearchResult Search(int sx, int sy, int ex, int ey, int dps = 1, int speed = 1, long long etime = -1);

    SearchResult Search2(int sx, int sy, int ex, int ey, int dps = 1, int speed = 1, long long etime = -1);

    Navigation & Init(std::shared_ptr<Map> map);

    Navigation & Clear();

    bool IsInited() const {
        return _inited;
    }

    std::string ToString(const std::vector<int>& path = std::vector<int>()) {
        std::stringstream ss;
        std::unordered_map<int, int> m;
        int i = 0;
        for (auto k : path)
        {
            m[k] = i;
            i++;
            i %= 10;
        }
        for (int y = 0; y < _map->GetHeight(); y++)
        {
            for (int x = 0; x < _map->GetWidth(); x++)
            {
                int index = _map->GetIndex(x, y);
                auto g = _map->GetGround(index);
                if (m.find(index) != m.end())
                {
                    ss << '[' << m[index] << ']';
                }
                else if (G_bErrorPrint && _pheromMap[index][*path.rbegin()] > 0)
                {
                    ss << "[*]";
                }
                else if (g->GetHeight() == 0)
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

    Navigation & AnalysisMap();

    int FindEmptyRect(int index);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetEmptyRectGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetEmptyRectGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetNearGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetNearGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetNearGrounds2(std::unordered_set<int>& close, int ground, int target, int dps, int speed);

    std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetOpenGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed);

   std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetOpenGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed);

   std::shared_ptr<BinHeap<std::pair<Distance, int>>> GetOpenGrounds2(std::unordered_set<int>& close, int ground, int target, int dps, int speed);

    std::unordered_set<int>& AddClose(std::unordered_set<int>& close, Ground* g1, Ground* g2);

    std::unordered_set<int>& AddClose(std::unordered_set<int>& close, int index1, int index2);

    std::unordered_set<int>& RemoveClose(std::unordered_set<int>& close, int index1, int index2);

    bool IsInClose(std::unordered_set<int>& close, Ground* g1, Ground* g2);

    bool IsInClose(std::unordered_set<int>& close, int index1, int index2);

    int CalcuDistance(Ground* g1, Ground* g2, int dps, int speed);

    int CalcuDistance(int index1, int index2, int dps, int speed);

    int ExpectDistance(Ground* g1, Ground* g2);

    int ExpectDistance(int index1, int index2);

    bool StartSearch(Ground* g, Ground* target, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps = 1, int speed = 1, long long etime = -1);

    bool StartSearch(int start, int end, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps = 1, int speed = 1, long long etime = -1);

    bool StartSearch2(int start, int end, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps = 1, int speed = 1, long long etime = -1);

    void CleanObstacle(const std::list<int>& grounds);

private:

    bool _inited;

    std::shared_ptr<Map> _map;

    std::unordered_map<int, std::shared_ptr<std::unordered_set<int>>> _emptyMap;

    std::unordered_map<int, std::unordered_map<int, int>> _pheromMap;
};

Navigation::Navigation()
{
    _inited = false;
}

Navigation::~Navigation()
{
}

inline Navigation::SearchResult Navigation::Search(int sx, int sy, int ex, int ey, int dps, int speed, long long duration)
{
    std::unordered_set<int> close;
    std::shared_ptr<Distance>d;
    int sindex = _map->GetIndex(sx, sy);
    int eindex = _map->GetIndex(ex, ey);
    std::list<int> path;
    BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>> opens;
    opens.Init([](const std::pair<Distance, std::shared_ptr<OpenNode>>& a, const std::pair<Distance, std::shared_ptr<OpenNode>>& b) {
        if (a.first == b.first)
            return a.first.left < b.first.left;
        else
            return a.first < b.first;
    });
    bool bIsSuccess = false;
    if (sindex != -1 && eindex != -1)
    {
        bIsSuccess = StartSearch(sindex, eindex, opens, close, dps, speed, duration > 0 ? ::GetTickCount() + duration : -1);
    }
    if (opens.GetSize() > 0)
    {
        auto open = opens.Get(0);
        auto p = open.second;
        while (p)
        {
            path.push_front(p->index);
            p = p->last;
        }
        CleanObstacle(path);
        /*for (auto i : path)
        {
            for (auto j : path)
            {
                if (i != j)
                {
                    _pheromMap[i][j] = 1;
                }
            }
        }*/
        return Navigation::SearchResult(bIsSuccess, open.first, path, close);
    }
    else
        return Navigation::SearchResult(false, Distance(0, 0), std::list<int>(), close);
}

inline Navigation::SearchResult Navigation::Search2(int sx, int sy, int ex, int ey, int dps, int speed, long long duration)
{
    std::unordered_set<int> close;
    std::shared_ptr<Distance>d;
    int sindex = _map->GetIndex(sx, sy);
    int eindex = _map->GetIndex(ex, ey);
    std::list<int> path;
    BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>> opens;
    opens.Init([](const std::pair<Distance, std::shared_ptr<OpenNode>>& a, const std::pair<Distance, std::shared_ptr<OpenNode>>& b) {
        if (a.first == b.first)
            return a.first.left < b.first.left;
        else
            return a.first < b.first;
    });
    if (sindex != -1 && eindex != -1)
    {
        StartSearch2(sindex, eindex, opens, close, dps, speed, duration > 0 ? ::GetTickCount() + duration : -1);
    }
    if (opens.GetSize() > 0)
    {
        auto open = opens.Get(0);
        auto p = open.second;
        while (p)
        {
            path.push_front(p->index);
            p = p->last;
        }
        bool bIsSuccess = *path.rbegin() == eindex;
        return Navigation::SearchResult(bIsSuccess, open.first, path, close);
    }
    else
        return Navigation::SearchResult(false, Distance(0, 0), std::list<int>(), close);
}

inline Navigation & Navigation::Init(std::shared_ptr<Map> map)
{
    _map = map;
    _inited = true;
    return *this;
}

inline Navigation & Navigation::Clear()
{
    _map = nullptr;
    _inited = false;
    return *this;
}

inline std::unordered_set<int>& Navigation::AddClose(std::unordered_set<int>& close, Ground* g1, Ground* g2)
{
    int index1 = _map->GetIndex(*g1);
    int index2 = _map->GetIndex(*g2);
    return AddClose(close, index1, index2);
}

inline std::unordered_set<int>& Navigation::AddClose(std::unordered_set<int>& close, int index1, int index2)
{
    int len = _map->GetWidth() * _map->GetHeight();
    if (index1 > index2)
        close.insert(index1 * len + index2);
    else
        close.insert(index2 * len + index1);
    return close;
}

inline std::unordered_set<int>& Navigation::RemoveClose(std::unordered_set<int>& close, int index1, int index2)
{
    int len = _map->GetWidth() * _map->GetHeight();
    if (index1 > index2)
        close.erase(index1 * len + index2);
    else
        close.erase(index2 * len + index1);
    return close;
}

inline bool Navigation::IsInClose(std::unordered_set<int>& close, Ground* g1, Ground* g2)
{
    int index1 = _map->GetIndex(*g1);
    int index2 = _map->GetIndex(*g2);
    return IsInClose(close, index1, index2);
}

inline bool Navigation::IsInClose(std::unordered_set<int>& close, int index1, int index2)
{
    int len = _map->GetWidth() * _map->GetHeight();
    if (index1 > index2)
        return close.find(index1 * len + index2) != close.end();
    else
        return close.find(index2 * len + index1) != close.end();
}

inline Navigation & Navigation::AnalysisMap()
{
    int minWidth = 2;
    int minHeight = 2;
    for (int y = 0; y < _map->GetHeight(); y++)
    {
        for (int x = 0; x < _map->GetWidth();)
        {
            int width = 0;
            int height = -1;
            int offX = 0;
            int offY = 0;
            int cx = x + offX;
            int cy = y + offY;
            int index = _map->GetIndex(cx, cy);
            int oindex = FindEmptyRect(index);
            if (index != -1 && oindex != -1)
            {
                int x1 = _map->GetX(index);
                int y1 = _map->GetY(index);
                int x2 = _map->GetX(oindex);
                int y2 = _map->GetY(oindex);

                if (x2 - x1 < minWidth || y2 - y1 < minHeight)
                {
                    x++;
                    continue;
                }

                std::shared_ptr<std::vector<int>> grounds(new std::vector<int>);
                for (int x = x1 - 1; x <= x2 + 1; x++)
                {
                    for (int y = y1 - 1; y <= y2 + 1; y++)
                    {
                        if (x == x1 - 1 || y == y1 - 1 || x == x2 + 1 || y == y2 + 1)
                        {
                            int index = _map->GetIndex(x, y);
                            if (index != -1)
                                grounds->push_back(index);
                        }
                    }
                }
                for (int x = x1; x <= x2; x++)
                {
                    for (int y = y1; y <= y2; y++)
                    {
                        int index = _map->GetIndex(x, y);
                        if (index != -1)
                        {
                            if (_emptyMap.find(index) == _emptyMap.end())
                                _emptyMap[index] = std::shared_ptr<std::unordered_set<int>>(new std::unordered_set<int>(grounds->begin(), grounds->end()));
                            else
                            {
                                for (auto g : *grounds)
                                {
                                    _emptyMap[index]->insert(g);
                                }
                            }
                        }
                    }
                }
                x = x2 + 1;
            }
            else
                x++;
        }
    }
    return *this;
}

inline int Navigation::FindEmptyRect(int index)
{
    if (index != -1)
    {
        Ground* g = _map->GetGround(index);
        if (g->GetHeight() != 0)
        {
            return -1;
        }
        int x = g->GetX();
        int y = g->GetY();
        bool bLockW = false;
        bool bLockH = false;
        bool bDirW = true;
        int width = 0;
        int height = 0;
        int len = 1;
        while (1)
        {
            for (int i = 0; i < len; i++)
            {
                int cx = x + width;
                int cy = y + height;
                if (bDirW)
                    cx = x + i;
                else
                    cy = y + i;
                index = _map->GetIndex(cx, cy);
                g = _map->GetGround(index);
                if (!g || g->GetHeight() != 0)
                {
                    if (bDirW)
                    {
                        bLockW = true;
                    }
                    else
                    {
                        bLockH = true;
                    }
                    break;
                }
            }
            if (bLockH || bLockW)
            {
                if (bDirW)
                    height++;
                else
                    width++;
            }
            else
            {
                if (bDirW)
                    width++;
                else
                    height++;
            }

            bDirW = bLockW ? false : bLockH ? true : !bDirW;

            if (bDirW && !bLockH)
            {
                len++;
            }

            if (bLockH && bLockW)
            {
                break;
            }
        }
        return _map->GetIndex(x + width - 2, y + height - 2);
    }
    return index;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetEmptyRectGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed)
{
    int index = _map->GetIndex(ground);
    int tindex = _map->GetIndex(target);
    return GetEmptyRectGrounds(close, index, tindex, dps, speed);
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetEmptyRectGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed)
{
    int cindex = ground;
    int tindex = target;
    auto itr = _emptyMap.find(cindex);
    if (itr != _emptyMap.end())
    {
        std::shared_ptr<BinHeap<std::pair<Distance, int>>> ret(new BinHeap<std::pair<Distance, int>>());
        ret->Init([](std::pair<Distance, int>& a, std::pair<Distance, int>& b) {
            return false;
        });
        auto vec = *itr->second;
        for (auto index : vec)
        {
            if (IsInClose(close, cindex, index))
                continue;
            if (index == tindex)
            {
                ret->Clear();
                ret->Add(std::pair<Distance, int>(Distance(), index));
                return ret;
            }
            ret->Add(std::pair<Distance, int>(Distance(CalcuDistance(cindex, index, dps, speed), ExpectDistance(index, tindex)), index));
        }
        return ret;
    }
    return nullptr;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetNearGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed)
{
    int cindex = _map->GetIndex(ground);
    int tindex = _map->GetIndex(target);
    return GetNearGrounds(close, cindex, tindex, dps, speed);
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetNearGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed)
{
    int x = _map->GetX(ground);
    int y = _map->GetY(ground);
    int cindex = ground;
    int tindex = target;
    //bool bHasPherom = _pheromMap[cindex][tindex] > 0;
    std::shared_ptr<BinHeap<std::pair<Distance, int>>> ret(new BinHeap<std::pair<Distance, int>>());
    ret->Init([](std::pair<Distance, int>& a, std::pair<Distance, int>& b) {
        return false;
    });

    //bool bFindPherom = false;

    for (int i = y - 1; i <= y + 1; i++)
    {
        for (int j = x - 1; j <= x + 1; j++)
        {
            int index = _map->GetIndex(j, i);
            if (index != -1 && index != cindex && !IsInClose(close, cindex, index))
            {
                if (index == tindex)
                {
                    ret->Clear();
                    ret->Add(std::pair<Distance, int>(Distance(), index));
                    return ret;
                }
                //if (bHasPherom)
                //{
                //    if (bFindPherom && _pheromMap[index][tindex] <= 0)
                //        continue;
                //    if (!bFindPherom && _pheromMap[index][tindex] > 0)
                //    {
                //        bFindPherom = true;
                //        ret->Clear();
                //    }
                //}
                ret->Add(std::pair<Distance, int>(Distance(CalcuDistance(cindex, index, dps, speed), ExpectDistance(index, tindex)), index));
            }
        }
    }
    return ret;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetNearGrounds2(std::unordered_set<int>& close, int ground, int target, int dps, int speed)
{
    std::shared_ptr<BinHeap<std::pair<Distance, int>>> ret(new BinHeap<std::pair<Distance, int>>());
    ret->Init([](std::pair<Distance, int>& a, std::pair<Distance, int>& b) {
        return false;
    });
    int x = _map->GetX(ground);
    int y = _map->GetY(ground);
    int cindex = ground;
    int tindex = target;
    for (int i = y - 1; i <= y + 1; i++)
    {
        for (int j = x - 1; j <= x + 1; j++)
        {
            int index = _map->GetIndex(j, i);
            if (index != -1 && index != cindex && !IsInClose(close, cindex, index))
            {
                if (index == tindex)
                {
                    ret->Clear();
                    ret->Add(std::pair<Distance, int>(Distance(), index));
                    return ret;
                }
                ret->Add(std::pair<Distance, int>(Distance(CalcuDistance(cindex, index, dps, speed), ExpectDistance(index, tindex)), index));
            }
        }
    }
    return ret;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetOpenGrounds(std::unordered_set<int>& close, Ground* ground, Ground* target, int dps, int speed)
{
    auto open = GetEmptyRectGrounds(close, ground, target, dps, speed);
    if (!open || open->GetSize() == 0)
    {
        open = GetNearGrounds(close, ground, target, dps, speed);
    }
    return open;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetOpenGrounds(std::unordered_set<int>& close, int ground, int target, int dps, int speed)
{
    auto open = GetEmptyRectGrounds(close, ground, target, dps, speed);
    if (!open || open->GetSize() == 0)
    {
        open = GetNearGrounds(close, ground, target, dps, speed);
    }
    return open;
}

inline std::shared_ptr<BinHeap<std::pair<Navigation::Distance, int>>> Navigation::GetOpenGrounds2(std::unordered_set<int>& close, int ground, int target, int dps, int speed)
{
    return GetNearGrounds2(close, ground, target, dps, speed);
}

inline int Navigation::CalcuDistance(Ground* g1, Ground* g2, int dps, int speed)
{
    int dis = ExpectDistance(g1, g2);
    return dis + g2->GetHeight() / dps * speed;
}

inline int Navigation::CalcuDistance(int index1, int index2, int dps, int speed)
{
    int h = _map->GetGround(index2)->GetHeight();
    int dis = ExpectDistance(index1, index2);
    return dis + h / dps * speed;
}

inline int Navigation::ExpectDistance(Ground* g1, Ground* g2)
{
    int x = abs(g1->GetX() - g2->GetX());
    int y = abs(g1->GetY() - g2->GetY());
    return min(x, y) * 14 + abs(x - y) * 10;
}

inline int Navigation::ExpectDistance(int index1, int index2)
{
    int x = abs(_map->GetX(index1) - _map->GetX(index2));
    int y = abs(_map->GetY(index1) - _map->GetY(index2));
    return min(x, y) * 14 + abs(x - y) * 10;
}

inline bool Navigation::StartSearch(Ground* g, Ground* target, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps, int speed, long long etime)
{
    int index = _map->GetIndex(g);
    int tindex = _map->GetIndex(target);
    return StartSearch(index, tindex, opens, close, dps, speed, etime);
}

inline bool Navigation::StartSearch(int start, int end, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps, int speed, long long etime)
{
    //std::vector<int> p;
    auto startNode = std::shared_ptr<OpenNode>(new OpenNode(start));
    if (opens.GetSize() == 0)
    {
        opens.Add(std::pair<Distance, std::shared_ptr<OpenNode>>(Distance(0, ExpectDistance(start, end)), startNode));
        //p.push_back(start);
    }

    std::unordered_map<int, int> minOpenMap;

    while ((start != end))
    {
        if (etime != -1 && ::GetTickCount() >= etime)
            return false;
        if (opens.GetSize() == 0)
            return false;
        auto open = GetOpenGrounds(close, start, end, dps, speed);
        auto node = opens.Get(0);
        opens.Remove(0);
        while (open->GetSize() > 0)
        {
            auto next = open->Get(0);
            Distance d(node.first + next.first);
            if (minOpenMap[next.second] > d.walk || minOpenMap[next.second] == 0)
            {
                minOpenMap[next.second] = d.walk;
                auto newOpen = std::shared_ptr<OpenNode>(new OpenNode(next.second, node.second));
                opens.Add(std::pair<Distance, std::shared_ptr<OpenNode>>(d, newOpen));
            }
            AddClose(close, start, next.second);
            open->Remove(0);
            //p.push_back(next.second);
        }

        //if (G_bErrorPrint)
        //{
        //    //std::cout << ToString(p) << std::endl;
        //    Sleep(1000);
        //}

        if (opens.GetSize() > 0)
        {
            start = opens.Get(0).second->index;
        }
    }
    return start == end;
}

inline bool Navigation::StartSearch2(int start, int end, BinHeap<std::pair<Distance, std::shared_ptr<OpenNode>>>& opens, std::unordered_set<int>& close, int dps, int speed, long long etime)
{
    if (opens.GetSize() == 0)
    {
        opens.Add(std::pair<Distance, std::shared_ptr<OpenNode>>(Distance(0, ExpectDistance(start, end)), std::shared_ptr<OpenNode>(new OpenNode(start, nullptr))));
    }

    std::unordered_map<int, int> minOpenMap;

    while ((start != end))
    {
        if (etime != -1 && ::GetTickCount() >= etime)
            return false;
        if (opens.GetSize() == 0)
            return false;
        auto open = GetOpenGrounds2(close, start, end, dps, speed);
        auto node = opens.Get(0);
        opens.Remove(0);
        while (open->GetSize() > 0)
        {
            auto next = open->Get(0);
            Distance d(node.first + next.first);
            if (minOpenMap[next.second] > d.walk || minOpenMap[next.second] == 0)
            {
                minOpenMap[next.second] = d.walk;
                auto newOpen = std::shared_ptr<OpenNode>(new OpenNode(next.second, node.second));
                opens.Add(std::pair<Distance, std::shared_ptr<OpenNode>>(d, newOpen));
            }
            AddClose(close, start, next.second);
            open->Remove(0);
        }

        if (opens.GetSize() > 0)
        {
            start = opens.Get(0).second->index;
        }
    }
    return start == end;
}

inline void Navigation::CleanObstacle(const std::list<int>& grounds)
{
    for (auto i : grounds)
    {
        auto g = _map->GetGround(i);
        //int index = _map->GetIndex(g);
        if (g->GetHeight() > 0)
        {
            g->SetHeight(0);
            //_pheromMap.clear();
        }
    }
}
