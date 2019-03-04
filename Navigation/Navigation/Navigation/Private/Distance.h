#pragma once

#include "../Public/IDistance.h"

class Distance : public IDistance
{
public:
	using  ptrD = std::shared_ptr<IDistance>;

	Distance() : IDistance() {
		_last = nullptr;
		_index = 0;
		_w = 0;
		_l = 0;
	};
	~Distance() {
	};

	virtual Distance * Init(int index, int w, int l, std::shared_ptr<IDistance> last = nullptr);
	virtual bool operator<(const IDistance & b) const;
	virtual bool operator>(const IDistance & b) const;
	virtual bool operator==(const IDistance & b) const;
	virtual Distance & operator+=(const IDistance & b);
	virtual std::shared_ptr<IDistance> GetLast();
	virtual int GetIndex() const;
	virtual int GetWalk() const;
	virtual int GetLeft() const;
	virtual Distance * SetLast(std::shared_ptr<IDistance> last);
	virtual Distance * SetWalk(int w);
	virtual Distance * SetLeft(int l);

private:

	std::shared_ptr<IDistance> _last;
	int _index;
	int _w;
	int _l;

};


inline Distance * Distance::Init(int index, int w, int l, std::shared_ptr<IDistance> last /*= nullptr*/)
{
	_index = index;
	_w = w;
	_l = l;
	_last = last;
	return this;
}

inline bool Distance::operator<(const IDistance & b) const
{
	if (*this == b)
		return _l < b.GetLeft();
	else
		return _l + _w < b.GetLeft() + b.GetWalk();
}

inline bool Distance::operator>(const IDistance & b) const
{
	if (*this == b)
		return _l > b.GetLeft();
	else
		return _l + _w > b.GetLeft() + b.GetWalk();
}

inline bool Distance::operator==(const IDistance & b) const
{
	return _l + _w == b.GetLeft() + b.GetWalk();
}

inline Distance & Distance::operator+=(const IDistance & b)
{
	_w += b.GetWalk();
	return *this;
}

inline std::shared_ptr<IDistance> Distance::GetLast()
{
	return _last;
}

inline int Distance::GetIndex() const
{
	return _index;
}

inline int Distance::GetWalk() const
{
	return _w;
}

inline int Distance::GetLeft() const
{
	return _l;
}

inline Distance * Distance::SetLast(std::shared_ptr<IDistance> last)
{
	_last = last;
	return this;
}

inline Distance * Distance::SetWalk(int w)
{
	_w = w;
	return this;
}

inline Distance * Distance::SetLeft(int l)
{
	_l = l;
	return this;
}
