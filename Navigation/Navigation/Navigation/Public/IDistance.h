#pragma once

#include <memory>

class IDistance
{
public:
	typedef std::shared_ptr<IDistance> ptrD;

	virtual IDistance * Init(int index, int w, int l, std::shared_ptr<IDistance> last) = 0;
	virtual bool operator<(const IDistance & b) const = 0;
	virtual bool operator>(const IDistance & b) const = 0;
	virtual bool operator==(const IDistance & b) const = 0;
	virtual IDistance & operator+=(const IDistance & b) = 0;
	virtual std::shared_ptr<IDistance> GetLast() = 0;
	virtual int GetIndex() const = 0;
	virtual int GetWalk() const = 0;
	virtual int GetLeft() const = 0;
	virtual IDistance * SetLast(std::shared_ptr<IDistance> last) = 0;
	virtual IDistance * SetWalk(int w) = 0;
	virtual IDistance * SetLeft(int l) = 0;
};
