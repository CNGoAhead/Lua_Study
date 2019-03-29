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
	ReadWrite = 0x03,
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
int Encrypt(int value) {
	return value * 2 + 3;
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
double Encrypt(double value) {
	return int(value) * 2 + 3 + std::fmod(value, 1);
}

template<>
float Decrypt(float value) {
	return (int(value) - 3) / 2 + std::fmodf(value, 1);
}

template<>
float Encrypt(float value) {
	return int(value) * 2 + 3 + std::fmodf(value, 1);
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

template<typename T>
class PropAccessException<T&> : std::exception
{
public:
	PropAccessException(const char * const message, const T & v) : std::exception(message) {
		value = v;
	}
	T value;
};

template<
	typename C,
	typename T,
	Access F = Access::ReadWrite,
	typename G = std::function<T&()>,
	typename S = std::function<void(const T&)>
>
class PropertyBase {
private:
	template<typename P1 = T, typename P2 = C>
	class Event
	{
	public:
		void operator()(const P1 & p1, P2 & p2) {
			for (auto calls : _calls)
				for (auto call : calls.second)
					call(p1, p2);
		}

		void Add(void * tag, const std::function<void(const P1 &, P2 &)> & call) {
			_calls[int(tag)].push_back(call);
		}

		void Clear(void * tag) {
			_calls[int(tag)].clear();
		}

	private:
		std::unordered_map<long long, std::vector<std::function<void(const P1 &, P2 &)>>> _calls;
	};


public:
	PropertyBase(T v = T(), C * c = nullptr, const G & g = G(), const S & s = S())
		: _bLocked(false), _value(v), _this(c), _get(g), _set(s)
	{
	}
	~PropertyBase() {
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

	void Bind(void * tag, const std::function<void(const T&, C*)> & call) {
		_onChange.Add(tag, call);
	}

	void UnBind(void * tag) {
		_onChange.Clear(tag);
	}

protected:
	bool _bLocked;
	C * _this;
	T _value;
	G _get;
	S _set;
	Event<T, C*> _onChange;
};

template<
	typename C,
	typename T,
	Access F = Access::ReadWrite,
	typename G = std::function<T & ()>,
	typename S = std::function<void(const T &)>
>
class PropertyRef : public PropertyBase<C, T, F, G, S>
{
public:
	PropertyRef(T v) : PropertyBase<C, T, F, G, S>(v){
	}
	PropertyRef(C * t, T v) : PropertyBase<C, T, F, G, S>(v, t) {
	}
	PropertyRef(C * t, T v, const G & g) : PropertyBase<C, T, F, G, S>(v, t, g) {
	}
	PropertyRef(C * t, T v, const S & s) : PropertyBase<C, T, F, G, S>(v, t, G(), s) {
	}
	PropertyRef(C * t, T v, const G & g, const S & s) : PropertyBase<C, T, F, G, S>(v, t, g, s) {
	}
	~PropertyRef() {
	}

	T & RealGet() {
		return PropertyBase<C, T, F, G, S>::_value;
	}

	void RealSet(const T & v) {
		PropertyBase<C, T, F, G, S>::_value = v;
	}

	T & Get() {
		if (!(F | int(Access::Read)))
			throw PropAccessException<T>("this property is write only", RealGet());

		if (PropertyBase<C, T, F, G, S>::_get)
			return PropertyBase<C, T, F, G, S>::_get();
		return RealGet();
	}

	void Set(const T & v) {
		if (!(F | int(Access::Write)))
			throw PropAccessException<T>("this property is read only", v);

		if (PropertyBase<C, T, F, G, S>::_bLocked)
			return;

		if (&v != &PropertyBase<C, T, F, G, S>::_value)
			PropertyBase<C, T, F, G, S>::_onChange(v, PropertyBase<C, T, F, G, S>::_this);

		if (PropertyBase<C, T, F, G, S>::_set)
			PropertyBase<C, T, F, G, S>::_set(v);
		else
			RealSet(v);
	}

	operator T&() {
		return Get();
	}

	T & operator=(T & v) {
		Set(v);
		return Get();
	}

	T * operator->() {
		return &Get();
	}
};

template<
	typename C,
	typename T,
	Access F = Access::ReadWrite,
	typename G = std::function<T()>,
	typename S = std::function<void(const T)>
>
class Property : public PropertyBase<C, T, F, G, S>
{
public:
	Property(T v) : PropertyBase<C, T, F, G, S>(v) {
		Set(v);
	}
	Property(C * t, T v) : PropertyBase<C, T, F, G, S>(v, t) {
		Set(v);
	}
	Property(C * t, T v, const G & g) : PropertyBase<C, T, F, G, S>(v, t, g) {
		Set(v);
	}
	Property(C * t, T v, const S & s) : PropertyBase<C, T, F, G, S>(v, t, G(), s) {
		Set(v);
	}
	Property(C * t, T v, const G & g, const S & s) : PropertyBase<C, T, F, G, S>(v, t, g, s) {
		Set(v);
	}
	~Property() {
	}

	T RealGet() {
		return Decrypt<T>(PropertyBase<C, T, F, G, S>::_value);
	}

	void RealSet(const T & v) {
		PropertyBase<C, T, F, G, S>::_value = Encrypt<T>(v);
	}

	T Get() {
		if (!(int(F) | int(Access::Read)))
			throw PropAccessException<T>("this property is write only", RealGet());

		if (PropertyBase<C, T, F, G, S>::_get)
			return PropertyBase<C, T, F, G, S>::_get();
		return RealGet();
	}

	void Set(T v) {
		if (!(int(F) | int(Access::Write)))
			throw PropAccessException<T>("this property is read only", v);

		if (PropertyBase<C, T, F, G, S>::_bLocked)
			return;

		if (v != RealGet())
			PropertyBase<C, T, F, G, S>::_onChange(v, PropertyBase<C, T, F, G, S>::_this);

		if (PropertyBase<C, T, F, G, S>::_set)
			PropertyBase<C, T, F, G, S>::_set(v);
		else
			RealSet(v);
	}

	operator T() {
		return Get();
	}

	T operator=(T v) {
		Set(v);
		return Get();
	}

};

template<
	typename C,
	typename T,
	Access Flag = Access::ReadWrite,
	typename G = std::function<T&()>,
	typename S = std::function<void(T&)>,
	bool IsClass = std::is_class<T>::value,
	bool IsRef = std::is_reference<T>::value
>
struct Prop {
	using Type = void;
};

template<
	typename C,
	typename T,
	Access Flag
>
struct Prop <C, T&, Flag, std::function<T & ()>, std::function<void(T&)>, true, true> {
	using Type = PropertyRef<C, T, Flag, std::function<T & ()>, std::function<void(T&)>>;
};

template<
	typename C,
	typename T,
	Access Flag
>
struct Prop <C, T&, Flag, std::function<T()>, std::function<void(T)>, false, true> {
	using Type = Property<C, T, Flag, std::function<T()>, std::function<void(T)>>;
};


template<
	typename C,
	typename T,
	Access Flag,
	typename G,
	typename S
>
struct Prop <C, T&, Flag, G, S, true, true> {
	using Type = PropertyRef<C, T, Flag, G, S>;
};

template<
	typename C,
	typename T,
	Access Flag,
	typename G,
	typename S
>
struct Prop <C, T&, Flag, G, S, false, true> {
	using Type = Property<C, T, Flag, G, S>;
};

template<
	typename C,
	typename T,
	Access Flag
>
struct Prop <C, T, Flag, std::function<T & ()>, std::function<void(T&)>, true, false> {
	using Type = PropertyRef<C, T, Flag, std::function<T & ()>, std::function<void(T&)>>;
};

template<
	typename C,
	typename T,
	Access Flag
>
struct Prop <C, T, Flag, std::function<T()>, std::function<void(T)>, false, false> {
	using Type = Property<C, T, Flag, std::function<T()>, std::function<void(T)>>;
};


template<
	typename C,
	typename T,
	Access Flag,
	typename G,
	typename S
>
struct Prop <C, T, Flag, G, S, true, false> {
	using Type = PropertyRef<C, T, Flag, G, S>;
};

template<
	typename C,
	typename T,
	Access Flag,
	typename G,
	typename S
>
struct Prop <C, T, Flag, G, S, false, false> {
	using Type = Property<C, T, Flag, G, S>;
};
