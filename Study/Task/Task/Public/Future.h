#pragma once

#include <functional>
#include <vector>

template<typename T>
class Future
{
public:
	enum class State
	{
		Unkown,
		Valid,
		UnValid,
	};

	Future() = default;
	virtual ~Future() = default;

	void Valid() {
		_state = State::Valid;
		for (auto c : _calls)
			c(*this);
	}

	void UnValid() {
		_state = State::UnValid;
		for (auto c : _ncalls)
			c(*this);
	}

	bool IsValid() const { return _state == State::Valid; };
	bool IsUnValid() const { return _state == State::UnValid; };

	Future & OnValid(std::function<void(Future &)>&& call) {
		_calls.push_back(std::move(call));
		return *this;
	}

	Future & OnValid(std::function<void(Future &)>& call) {
		_calls.push_back(call);
		return *this;
	}

	Future & OnUnValid(std::function<void(Future &)>&& call) {
		_ncalls.push_back(std::move(call));
		return *this;
	}

	Future & OnUnValid(std::function<void(Future &)>& call) {
		_ncalls.push_back(call);
		return *this;
	}

	void Set(T&& value) {
		_value = std::forward<T>(value);
	}

	T Get() const {
		return _value;
	}

private:
	State _state = State::Unkown;

	std::vector<std::function<void(Future&)>> _calls;
	std::vector<std::function<void(Future&)>> _ncalls;

	T _value;
};

template<>
class Future<void>
{
public:
	enum class State
	{
		Unkown,
		Valid,
		UnValid,
	};

	Future() = default;
	virtual ~Future() = default;

	void Valid() {
		_state = State::Valid;
		for (auto c : _calls)
			c(*this);
	}

	void UnValid() {
		_state = State::UnValid;
		for (auto c : _ncalls)
			c(*this);
	}

	bool IsValid() const { return _state == State::Valid; };
	bool IsUnValid() const { return _state == State::UnValid; };

	Future & OnValid(std::function<void(Future &)>&& call) {
		_calls.push_back(std::move(call));
		return *this;
	}

	Future & OnValid(std::function<void(Future &)>& call) {
		_calls.push_back(call);
		return *this;
	}

	Future & OnUnValid(std::function<void(Future &)>&& call) {
		_ncalls.push_back(std::move(call));
		return *this;
	}

	Future & OnUnValid(std::function<void(Future &)>& call) {
		_ncalls.push_back(call);
		return *this;
	}

	void Set() {
	}

	void Get() const {
		return;
	}

private:
	State _state = State::Unkown;

	std::vector<std::function<void(Future&)>> _calls;
	std::vector<std::function<void(Future&)>> _ncalls;
};
