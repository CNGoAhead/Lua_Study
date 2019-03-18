#pragma once

#include <windows.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include <sstream>
#include <stack>

class TimeCost
{
public:
	TimeCost() {
		Clear();
		::QueryPerformanceFrequency(&_f);
	};
	~TimeCost() {
	}

	void Beg() {
		_se.push(LARGE_INTEGER());
		::QueryPerformanceCounter(&_se.top());
	}

	void End(std::string s, bool bPrint = false) {
		LARGE_INTEGER e;
		::QueryPerformanceCounter(&e);
		double t = (e.QuadPart - _se.top().QuadPart) / double(_f.QuadPart);
		_se.pop();
		_total += t;
		_t[s].second += t;
		_t[s].first++;
		if (bPrint)
		{
			std::cout << s << std::endl;
			std::cout << "Use Time / Times = " << _t[s].second << " / " << _t[s].first << std::endl;
			std::cout << "Cost time = " << t << std::endl;
			std::cout << "Total time = " << _total << std::endl;
		}
	}

	void Clear() {
		_t.clear();
		_se = std::stack<LARGE_INTEGER>();
		_total = 0;
	}

	std::string ToString() {
		std::stringstream ss;
		ss << "Total time = " << _total << std::endl;
		for (auto p : _t)
			std::cout << p.first << std::endl << "Use Time / Times = " << p.second.second << " / " << p.second.first << std::endl;
		return ss.str();
	}

private:

	std::unordered_map<std::string, std::pair<int, double>> _t;

	double _total;

	LARGE_INTEGER _f;

	std::stack<LARGE_INTEGER> _se;

};



