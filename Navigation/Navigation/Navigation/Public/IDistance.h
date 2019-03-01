#pragma once

class IDistance
{
public:
	virtual bool operator<(const IDistance & b) = 0;
	virtual bool operator>(const IDistance & b) = 0;
	virtual bool operator==(const IDistance & b) = 0;
	virtual bool operator+=(const IDistance & b) = 0;
	virtual bool operator+(const IDistance & b) = 0;
};
