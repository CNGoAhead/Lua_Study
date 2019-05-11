#pragma once

#include "./Future.h"
#include <memory>
#include <thread>
#include <vector>
#include <mutex>
#include <queue>
#include <map>
#include <chrono>

class Task
{
public:
	static std::shared_ptr<Task> GetInstance() {
		if (!Task::_pinstance)
			Task::_pinstance.reset(new Task());
		return Task::_pinstance;
	}

	static void Destroy() {
		Task::_pinstance = nullptr;
	}

	Task() {
		auto count = std::thread::hardware_concurrency();
		_threads.reserve(count);
		_bRun = true;
		for (decltype(count) i = 0; i < count; i++)
			_threads.push_back(std::thread([&]() {
			while (_bRun)
			{
				if (TryLock())
				{
					if (_tasks.size() > 0)
					{
						const auto t = _tasks.front();
						_tasks.pop();
						Unlock();

						t();
					}
					else
						Unlock();
				}
				std::this_thread::sleep_for(std::chrono::milliseconds(1));
			}
		}));
		for (auto& t : _threads)
			t.detach();
	}
	~Task() {
		_bRun = false;
		Lock();
		Unlock();
		try
		{
			for (auto& t : _threads)
				t.~thread();
		}
		catch (const std::exception&)
		{
			_threads.clear();
		}
		_threads.clear();
	};

	template<typename Ret, typename Func, typename... Args>
	auto AddTask(Func && f, Args && ...args)
	{
		auto pf = std::make_shared<Future<Ret>>();
		auto call = [pf, f, args...]() {
			pf->Set(f(args...));
			pf->Valid();
			return;
		};
		_tasks.push(call);
		return pf;
	}

	template<typename Func, typename... Args>
	auto AddTask(Func && f, Args && ...args)
	{
		auto pf = std::make_shared<Future<void>>();
		auto call = [pf, f, args...]() {
			f(args...);
			pf->Valid();
			return;
		};
		_tasks.push(call);
		return pf;
	}

	void Lock() { _lock.lock(); }
	void Unlock() { _lock.unlock(); }
	bool TryLock() { return _lock.try_lock(); }

private:
	static std::shared_ptr<Task> _pinstance;

	bool _bRun = false;
	std::mutex _lock;
	std::vector<std::thread> _threads;
	std::queue<std::function<void()>> _tasks;
};

std::shared_ptr<Task> Task::_pinstance = nullptr;