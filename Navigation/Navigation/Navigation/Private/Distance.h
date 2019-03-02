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

	virtual IDistance * Init(int index, int w, int l, std::shared_ptr<IDistance> last = nullptr);
	virtual bool operator<(const IDistance & b) const;
	virtual bool operator>(const IDistance & b) const;
	virtual bool operator==(const IDistance & b) const;
	virtual IDistance & operator+=(const IDistance & b);
	virtual std::shared_ptr<IDistance> GetLast();
	virtual int GetIndex() const;
	virtual int GetWalk() const;
	virtual int GetLeft() const;
	virtual IDistance * SetLast(std::shared_ptr<IDistance> last);
	virtual IDistance * SetWalk(int w);
	virtual IDistance * SetLeft(int l);

private:

	std::shared_ptr<IDistance> _last;
	int _index;
	int _w;
	int _l;

};


inline IDistance * Distance::Init(int index, int w, int l, std::shared_ptr<IDistance> last /*= nullptr*/)
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

inline IDistance & Distance::operator+=(const IDistance & b)
{
	_l = b.GetLeft();
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

inline IDistance * Distance::SetLast(std::shared_ptr<IDistance> last)
{
	_last = last;
	return this;
}

inline IDistance * Distance::SetWalk(int w)
{
	_w = w;
	return this;
}

inline IDistance * Distance::SetLeft(int l)
{
	_l = l;
	return this;
}
