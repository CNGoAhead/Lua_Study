#pragma once

#include "../Public/IGround.h"

namespace NS_Navigation {

	class Ground : public IGround
	{
	public:
		Ground() : IGround(), _x(0), _y(0), _h(0), _f(0), _a(0) {
		};
		~Ground() {
		};

		inline virtual IGround * Init(int x, int y, int h, unsigned short f);
		inline virtual int GetX() const;
		inline virtual int GetY() const;
		inline virtual int GetHeight() const;
		inline virtual int GetAttraction() const;
		inline virtual unsigned short GetFlag() const;
		inline virtual IGround * SetX(int x);
		inline virtual IGround * SetY(int y);
		inline virtual IGround * SetHeight(int h);
		inline virtual IGround * AddHeight(int h);
		inline virtual IGround * SubHeight(int h);
		inline virtual IGround * SetFlag(unsigned short f);
		inline virtual IGround * AddFlag(unsigned short f);
		inline virtual IGround * SubFlag(unsigned short f);
		inline virtual IGround * SetAttraction(int a);
		inline virtual IGround * AddAttraction(int a);
		inline virtual IGround * SubAttraction(int a);
		inline virtual bool HasFlag(unsigned short f);

	private:
		int _x;
		int _y;
		int _h;
		int _a;
		unsigned short _f;
	};

	IGround * Ground::Init(int x, int y, int h, unsigned short f)
	{
		_x = x;
		_y = y;
		_h = h;
		_f = f;
		return this;
	}

	int Ground::GetX() const
	{
		return _x;
	}

	int Ground::GetY() const
	{
		return _y;
	}

	int Ground::GetHeight() const
	{
		return _h;
	}

	inline int Ground::GetAttraction() const
	{
		return _a;
	}

	unsigned short Ground::GetFlag() const
	{
		return _f;
	}

	IGround * Ground::SetX(int x)
	{
		_x = x;
		return this;
	}

	IGround * Ground::SetY(int y)
	{
		_y = y;
		return this;
	}

	IGround * Ground::SetHeight(int h)
	{
		_h = h;
		return this;
	}

	IGround * Ground::AddHeight(int h)
	{
		_h += h;
		return this;
	}

	IGround * Ground::SubHeight(int h)
	{
		_h -= h;
		return this;
	}

	IGround * Ground::SetFlag(unsigned short f)
	{
		_f = f;
		return this;
	}

	IGround * Ground::AddFlag(unsigned short f)
	{
		_f |= f;
		return this;
	}

	IGround * Ground::SubFlag(unsigned short f)
	{
		_f &= ~f;
		return this;
	}

	inline IGround * Ground::SetAttraction(int a)
	{
		_a = a;
		return this;
	}

	inline IGround * Ground::AddAttraction(int a)
	{
		_a += a;
		return this;
	}

	inline IGround * Ground::SubAttraction(int a)
	{
		_a -= a;
		return this;
	}

	bool Ground::HasFlag(unsigned short f)
	{
		return _f & f;
	}

}