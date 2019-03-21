#pragma once

#include <functional>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <type_traits>

enum class Access
{
	Read = 0x01,
	Write = 0x02,
};

template<typename T>
T Encrypt(T value) {
	return value;
}

template<typename T>
T Decrypt(T value) {
	return value;
}

template<>
int * Encrypt(int * value) {
	(*value) = *value * 2 + 3;
	return value;
}

template<>
int Decrypt(int value) {
	return ((value) - 3) / 2;
}

template<>
double Decrypt(double value) {
	return (int(value) - 3) / 2 + std::fmod(value, 1);
}

template<>
double * Encrypt(double * value) {
	(*value) = int(*value) * 2 + 3 + std::fmod(value, 1);
	return value;
}

template<>
float Decrypt(float value) {
	return (int(value) - 3) / 2 + std::fmodf(value, 1);
}

template<>
float * Encrypt(float * value) {
	(*value) = int(*value) * 2 + 3 + std::fmodf(value, 1);
	return value;
}

template<typename T>
class PropAccessException : std::exception
{
public:
	PropAccessException(const char * const message, const T & v) : std::exception(message) {
		value = v;
	}
	T value;
};

template<
	typename Super,
	typename T,
	int Flag = (0x01 | 0x02),
	typename G = std::function<T & ()>,
	typename S = std::function<void(const T &)>
>
class PropertyRef
{
private:
	template<typename P1 = Super, typename P2 = T>
	class Event
	{
	public:
		void operator()(P1 & p1, const P2 & p2) {
			for (auto calls : _calls)
				for (auto call : calls.second)
					call(p1, p2);
		}

		void Add(void * tag, const std::function<void(P1 &, const P2 &)> & call) {
			_calls[int(tag)].push_back(call);
		}

		void Clear(void * tag) {
			_calls[int(tag)].clear();
		}

	private:
		std::unordered_map<long long, std::vector<std::function<void(P1 &, const P2 &)>>> _calls;
	};


public:
	PropertyRef(Super * t, T v) : _bLocked(false), _this(t), _value(v) {
	}
	PropertyRef(Super * t, T v, const G & g) : _bLocked(false), _this(t), _value(v), _get(g) {
	}
	PropertyRef(Super * t, T v, const S & s) : _bLocked(false), _this(t), _value(v), _set(s) {
	}
	PropertyRef(Super * t, T v, const G & g, const S & s) : _bLocked(false), _this(t), _value(v), _get(g), _set(s) {
	}
	~PropertyRef() {
	}

	T & RealGet() {
		return _value;
	}

	void RealSet(const T & v) {
		_value = v;
	}

	T & Get() {
		if (!(Flag | int(Access::Read)))
			throw PropAccessException<T>("this property is write only", RealGet());

		if (_get)
			return _get();
		return RealGet();
	}

	void Set(const T & v) {
		if (!(Flag | int(Access::Write)))
			throw PropAccessException<T>("this property is read only", v);

		if (_bLocked)
			return;

		if (&v != &_value)
			_onChange(*_this, v);

		if (_set)
			_set(v);
		else
			RealSet(v);
	}

	void Lock() {
		_bLocked = true;
	}

	void Unlock() {
		_bLocked = false;
	}

	void ToggleLock() {
		_bLocked = !_bLocked;
	}

	void Bind(void * tag, const std::function<void(Super&, const T&)> & call) {
		_onChange.Add(tag, call);
	}

	void UnBind(void * tag) {
		_onChange.Clear(tag);
	}

	operator T&() {
		return Get();
	}

	T & operator=(const T & v) {
		Set(v);
		return RealGet();
	}

	T * operator->() {
		return &Get();
	}

private:
	bool _bLocked;
	Super * _this;
	T _value;
	G _get;
	S _set;
	Event<Super, T> _onChange;
};

template<
	typename Super,
	typename T,
	int Flag = (0x01 | 0x02),
	typename G = std::function<T & ()>,
	typename S = std::function<void(const T &)>
>
class Property
{
private:
	template<typename P1 = Super, typename P2 = T>
	class Event
	{
	public:
		void operator()(P1 & p1, const P2 & p2) {
			for (auto calls : _calls)
				for (auto call : calls.second)
					call(p1, p2);
		}

		void Add(void * tag, const std::function<void(P1 &, const P2 &)> & call) {
			_calls[int(tag)].push_back(call);
		}

		void Clear(void * tag) {
			_calls[int(tag)].clear();
		}

	private:
		std::unordered_map<long long, std::vector<std::function<void(P1 &, const P2 &)>>> _calls;
	};


public:
	Property(Super * t, T v) : _bLocked(false), _this(t), _value(v) {
	}
	Property(Super * t, T v, const G & g) : _bLocked(false), _this(t), _value(v), _get(g) {
	}
	Property(Super * t, T v, const S & s) : _bLocked(false), _this(t), _value(v), _set(s) {
	}
	Property(Super * t, T v, const G & g, const S & s) : _bLocked(false), _this(t), _value(v), _get(g), _set(s) {
	}
	~Property() {
	}

	T RealGet() {
		return Decrypt<T>(_value);
	}

	void RealSet(const T & v) {
		_value = v;
		Encrypt<T*>(&_value);
	}

	T Get() {
		if (!(Flag | int(Access::Read)))
			throw PropAccessException<T>("this property is write only", RealGet());

		if (_get)
			return _get();
		return RealGet();
	}

	void Set(const T & v) {
		if (!(Flag | int(Access::Write)))
			throw PropAccessException<T>("this property is read only", v);

		if (_bLocked)
			return;

		if (&v != &_value)
			_onChange(*_this, v);

		if (_set)
			_set(v);
		else
			RealSet(v);
	}

	void Lock() {
		_bLocked = true;
	}

	void Unlock() {
		_bLocked = false;
	}

	void ToggleLock() {
		_bLocked = !_bLocked;
	}

	void Bind(void * tag, const std::function<void(Super&, const T&)> & call) {
		_onChange.Add(tag, call);
	}

	void UnBind(void * tag) {
		_onChange.Clear(tag);
	}

	operator T() {
		return Get();
	}

	T operator=(const T & v) {
		Set(v);
		return RealGet();
	}

private:
	bool _bLocked;
	Super * _this;
	T _value;
	G _get;
	S _set;
	Event<Super, T> _onChange;
};

template<
	typename Super,
	typename C,
	int Flag = (0x01 | 0x02),
	bool IsClass = std::is_class<C>::value,
	typename T = PropertyRef<Super, C, Flag, std::function<C & ()>, std::function<void(const C &)>>,
	typename F = Property<Super, C, Flag, std::function<C ()>, std::function<void(const C &)>>
>
struct Prop {
	using Type = void;
};

template<
	typename Super,
	typename C,
	int Flag
>
struct Prop <Super, C, Flag, true, PropertyRef<Super, C, Flag, std::function<C & ()>, std::function<void(const C &)>>, Property<Super, C, Flag, std::function<C()>, std::function<void(const C &)>>> {
	using Type = PropertyRef<Super, C, Flag, std::function<C & ()>, std::function<void(const C &)>>;
};

template<
	typename Super,
	typename C,
	int Flag
>
struct Prop <Super, C, Flag, false, PropertyRef<Super, C, Flag, std::function<C & ()>, std::function<void(const C &)>>, Property<Super, C, Flag, std::function<C()>, std::function<void(const C &)>>> {
	using Type = Property<Super, C, Flag, std::function<C()>, std::function<void(const C &)>>;
};
