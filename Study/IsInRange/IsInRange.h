#pragma once

#include <initializer_list>
#include <cmath>
#include <algorithm>

//#define max(a, b) ((a) > (b) ? (a) : (b))
//#define min(a, b) ((a) < (b) ? (a) : (b))

template<typename T = int, int L = 2>
class Vec
{
public:
	Vec() {
		for (int i = 0; i < L; i++)
			_v[i] = 0;
	}
	Vec(const Vec& v) {
		for (int i = 0; i < L; i++)
			_v[i] = v._v[i];
	}
	Vec(Vec<T, L - 1>& v, T a) {
		for (int i = 0; i < v.l; i++)
			_v[i] =  v._v[i];
		_v[L] = a;
	}
	Vec(Vec<T, L - 2>& v, T a, T b) {
		for (int i = 0; i < v.l; i++)
			_v[i] = v._v[i];
		_v[L - 1] = a;
		_v[L] = a;
	}
	Vec(Vec<T, L + 1>& v, T a) {
		for (int i = 0; i < L; i++)
			_v[i] = v._v[i];
	}
	Vec(Vec<T, L + 2>& v, T a, T b) {
		for (int i = 0; i < L; i++)
			_v[i] = v._v[i];
	}

	Vec(T v[L]) {
		for (int i = 0; i < L; i++)
		{
			_v[i] = v[i];
		}
	}
	Vec(T x, T y, T z, T w) {
		_v[0] = x;
		_v[1] = y;
		_v[2] = z;
		_v[3] = w;
	}
	Vec(T x, T y, T z) {
		_v[0] = x;
		_v[1] = y;
		_v[2] = z;
	}
	Vec(T x, T y) {
		_v[0] = x;
		_v[1] = y;
	}

	inline T Mod2() const {
		T t = T(0);
		for (auto i : _v)
			t += i * i;
		return t;
	}

	inline double Mod() const {
		return std::sqrt(Mod2());
	}

	inline double Dot(const Vec<T, L>& v) const {
		double t = 0;
		for (int i = 0; i < L; i++)
			t += _v[i] * v._v[i];
		return t;
	}

	inline Vec<T, L> operator=(const Vec<T, L>& v) {
		for (int i = 0; i < L; i++)
			_v[i] = v._v[i];
	}

	inline Vec<T, L> operator-(const Vec<T, L>& v) const {
		Vec<T, L>ret;
		for (int i = 0; i < L; i++)
			ret._v[i] = _v[i] - v._v[i];
		return ret;
	}

	inline Vec<T, L> operator+(const Vec<T, L>& v) const {
		Vec<T, L>ret;
		for (int i = 0; i < L; i++)
			ret._v[i] = _v[i] + v._v[i];
		return ret;
	}

	inline Vec<T, L> Crs(Vec<T, L>& v) const {
		return Vec<T, L>();
	}

	inline T X() const { return _v[0]; }
	inline T Y() const { return _v[1]; }
	inline T Z() const { return _v[2]; }
	inline T W() const { return _v[3]; }
	T _v[L];
	int l = L;
};

template<typename T>
Vec<T, 3> Crs(Vec<T, 3>& v) {
	// Vec<T, L> ret;
	// for (auto i = 0; i < L; i++)
	//	// x = y * z - z * y
	//	// y = z * x - x * z
	//	// z = x * y - y * z
	//	ret._v[i] = _v[(i + 1) % L] * v._v[(i + 2) % L] - _v[(i + 2) % L] * v._v[(i + 1) % L];
	return Vec<T, 3>(
			this->Y() * v.Z() - this->Z() * v.Y(),
			this->Z() * v.X() - this->X() * v.Z(),
			this->X() * v.Y() - this->Y() * v.X()
		);
}

template<typename T>
Vec<T, 4> Crs(Vec<T, 4>& v) {
	return Vec<T, 4>(
			Vec<T, 3>(*this).Crs(Vec<T, 3>(v)),
			0
		);
}

using Vector2 = Vec<double, 2>;

class IsInRange
{
public:
	IsInRange();
	~IsInRange();

	static bool IsInTriangle(const Vector2& A, const Vector2& B, const Vector2& C, const Vector2& P)
	{
		Vector2 v0 = C - A;
		Vector2 v1 = B - A;
		Vector2 v2 = P - A;

		double dot00 = v0.Dot(v0);
		double dot01 = v0.Dot(v1);
		double dot02 = v0.Dot(v2);
		double dot11 = v1.Dot(v1);
		double dot12 = v1.Dot(v2);

		double inverDeno = 1 / (dot00 * dot11 - dot01 * dot01);

		double u = (dot11 * dot02 - dot01 * dot12) * inverDeno;
		if (u < 0 || u > 1) // if u out of range, return directly
		{
			return false;
		}

		double v = (dot00 * dot12 - dot01 * dot02) * inverDeno;
		if (v < 0 || v > 1) // if v out of range, return directly
		{
			return false;
		}

		return u + v <= 1;
	}

	inline static bool IsInRect(const Vector2& LB, const Vector2& RT, const Vector2& P) {
		return P.X() >= std::min(LB.X(), RT.X())
			&& P.X() <= std::max(RT.X(), LB.X())
			&& P.Y() >= std::min(LB.Y(), RT.Y())
			&& P.Y() <= std::max(RT.Y(), LB.Y());
	}

	static bool IsInRect(const Vector2& A, const Vector2& B, const Vector2& C, const Vector2& P)
	{
		Vector2 v0 = C - A;
		Vector2 v1 = B - A;
		Vector2 v2 = P - A;

		double dot00 = v0.Dot(v0);
		double dot01 = v0.Dot(v1);
		double dot02 = v0.Dot(v2);
		double dot11 = v1.Dot(v1);
		double dot12 = v1.Dot(v2);

		double inverDeno = 1 / (dot00 * dot11 - dot01 * dot01);

		double u = (dot11 * dot02 - dot01 * dot12) * inverDeno;
		if (u < 0 || u > 1) // if u out of range, return directly
		{
			return false;
		}

		double v = (dot00 * dot12 - dot01 * dot02) * inverDeno;
		if (v < 0 || v > 1) // if v out of range, return directly
		{
			return false;
		}

		return u + v <= 2;
	}

	// FIXME: false
	static bool IsInSector(const Vector2& A, const Vector2& B, const Vector2& C, const Vector2& P)
	{
		Vector2 v0 = C - A;
		Vector2 v1 = B - A;
		Vector2 v2 = P - A;

		double dot00 = v0.Dot(v0);
		double dot01 = v0.Dot(v1);
		double dot02 = v0.Dot(v2);
		double dot11 = v1.Dot(v1);
		double dot12 = v1.Dot(v2);

		double inverDeno = 1 / (dot00 * dot11 - dot01 * dot01);

		double u = (dot11 * dot02 - dot01 * dot12) * inverDeno;
		if (u < 0 || u > 1) // if u out of range, return directly
		{
			return false;
		}

		double v = (dot00 * dot12 - dot01 * dot02) * inverDeno;
		if (v < 0 || v > 1) // if v out of range, return directly
		{
			return false;
		}

		return u * u + v * v <= 1;
	}

	static bool IsInRect2(const Vector2& A, const Vector2& B, const Vector2& C, const Vector2& D, const Vector2& P)
	{
		const Vector2* vL = &A;
		const Vector2* vR = &A;
		const Vector2* vT = &A;
		const Vector2* vB = &A;
		auto vec = { &B, &C, &D };
		for (auto v : vec)
		{
			if (v->X() > vR->X())
				vR = v;
			if (v->X() < vL->X())
				vL = v;
			if (v->Y() > vT->Y())
				vT = v;
			if (v->Y() < vB->Y())
				vB = v;
		}
		if (vL == vT || vL == vB)
			return IsInRect(*vL, *vR, P);

		auto h = vR->Y() - vB->Y();
		auto w = vR->X() - vB->X();
		auto l = sqrt(h * h + w * w);
		auto s = h / l;
		auto c = w / l;
		Vector2 vNR(vR->X() * c + vR->Y() * s, vR->X() * -s + vR->Y() * c);
		Vector2 vNL(vL->X() * c + vL->Y() * s, vL->X() * -s + vL->Y() * c);
		Vector2 vNP(P.X() * c + P.Y() * s, P.X() * -s + P.Y() * c);
		return IsInRect(vNL, vNR, vNP);
	}

private:

};

