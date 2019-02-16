#pragma once
#include <vector>
#include <functional>
#include <string>
#include <sstream>

template<class T>
class BinHeap
{
public:
    BinHeap();
    ~BinHeap();

private:

    static std::function<bool(T&, T&)> _Less;

public:

    BinHeap<T>& Init(std::function<bool(T&, T&)> compareFunc, std::vector<T> vals = std::vector<T>());

    BinHeap<T>& Init(std::vector<T> vals = std::vector<T>());

    BinHeap<T>& Clear() { _vec.clear(); return *this; };

    BinHeap<T>& Add(T var);

    BinHeap<T>& Remove(int index);

    BinHeap<T>& Remove(T val);

    int GetSize();

    T& Get(int index);

    using CIterator = typename std::vector<T>::const_iterator;
    using Iterator = typename std::vector<T>::iterator;
    using RIterator = typename std::vector<T>::reverse_iterator;

    CIterator CBegin() { return _vec.cbegin(); };

    CIterator CEnd() { return _vec.cend(); };

    Iterator Begin() { return _vec.begin(); };

    Iterator End() { return _vec.end(); };

    RIterator RBegin() { return _vec.rbegin(); };

    RIterator REnd() { return _vec.rend(); };

    std::string ToString() const {
        std::stringstream ss;
        int len = 1;
        int index = 1;
        for (auto i : _vec)
        {
            ss << i.ToString() << ' ';
            if (index >= len)
            {
                index = 1;
                len *= 2;
                ss << '\n';
            }
            else
            {
                index++;
            }
        }
        return ss.str();
    };

private:

    void SortOnAdd(int Index);

    void SortOnRemove(int Index);

private:

    std::function<bool(T&, T&)> _compare = _Less;

    std::vector<T> _vec;

};

template<class T>
BinHeap<T>::BinHeap()
{
}

template<class T>
BinHeap<T>::~BinHeap()
{
}

template<class T>
__declspec(selectany) std::function<bool(T&, T&)> BinHeap<T>::_Less = [](T var1, T var2)
{
    return var1 < var2;
};

template<class T>
inline BinHeap<T> & BinHeap<T>::Init(std::function<bool(T&, T&)> compareFunc, std::vector<T> vals)
{
    _compare = compareFunc;
    for (auto i : vals)
    {
        Add(i);
    }
    return *this;
}

template<class T>
inline BinHeap<T> & BinHeap<T>::Init(std::vector<T> vals)
{
    return Init(_Less, vals);
}

template<class T>
inline BinHeap<T> & BinHeap<T>::Add(T var)
{
    _vec.push_back(var);
    SortOnAdd(_vec.size() - 1);
    return *this;
}

template<class T>
inline BinHeap<T> & BinHeap<T>::Remove(int index)
{
    _vec[index] = _vec[_vec.size() - 1];
    _vec.pop_back();
    SortOnRemove(index);
    return *this;
}

template<class T>
inline BinHeap<T>& BinHeap<T>::Remove(T val)
{
    for (int i = 0; i < _vec.size(); i++)
    {
        if (_vec[i] == val)
        {
            Remove(i);
            break;
        }
    }
    return *this;
}

template<class T>
inline int BinHeap<T>::GetSize()
{
    return _vec.size();
}

template<class T>
inline T& BinHeap<T>::Get(int index)
{
    return _vec[index];
}

template<class T>
inline void BinHeap<T>::SortOnAdd(int index)
{
    if (index > 0)
    {
        int compareIndex = int((index - 1) / 2);
        if (_compare(_vec[index], _vec[compareIndex]))
        {
            T temp = _vec[index];
            _vec[index] = _vec[compareIndex];
            _vec[compareIndex] = temp;
            SortOnAdd(compareIndex);
        }
    }
}

template<class T>
inline void BinHeap<T>::SortOnRemove(int index)
{
    int compareIndexL = index * 2 + 1;
    int compareIndexR = index * 2 + 2;
    int compareIndex = -1;
    if (compareIndexL < _vec.size() && compareIndexR < _vec.size())
        compareIndex = _compare(_vec[compareIndexL], _vec[compareIndexR]) ? compareIndexL : compareIndexR;
    else if (compareIndexL < _vec.size())
        compareIndex = compareIndexL;
    else
        return;

    //SortOnAdd(index);
    if (_compare(_vec[compareIndex], _vec[index]))
    {
        T temp = _vec[index];
        _vec[index] = _vec[compareIndex];
        _vec[compareIndex] = temp;
        SortOnRemove(compareIndex);
    }
}
