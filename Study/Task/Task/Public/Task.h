#pragma once

#include "./Future.h"
#include <memory>
#include <thread>
#include <vector>
#include <mutex>
#include <list>
#include <map>

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
				_lock.lock();
				if (_tasks.size() > 0)
				{
					auto t = *_tasks.begin();
					_tasks.pop_front();
					_lock.unlock();

					t();
				}
				else
					_lock.unlock();
			}
		}));
		for (auto& t : _threads)
			t.detach();
	}
	~Task() {
		_bRun = false;
		for (auto& t : _threads)
		{
#ifdef _WIN32
			WaitForSingleObject(t.native_handle(), -1);
#endif // 
		}
		_threads.clear();
	};

	template<typename Ret, typename Func, typename... Args>
	auto AddTask(Func && f, Args && ...args)
	{
		auto pf = std::shared_ptr<Future<Ret>>(new Future<Ret>());
		_tasks.push_back([pf, &f, &args...]() {
			pf->Set(f(args...));
			pf->Valid();
			return;
		});
		return pf;
	}

	template<typename Func, typename... Args>
	auto AddTask(Func && f, Args && ...args) {
		auto pf = std::shared_ptr<Future<void>>(new Future<void>());
		_tasks.push_back([pf, &f, &args...]() {
			f(args...);
			pf->Valid();
			return;
		});
		return pf;
	}

	void Lock(const char* key = nullptr) { if (!key) _lock.lock(); else _locks[key].lock(); }
	void Unlock(const char* key = nullptr) { if (!key) _lock.unlock(); else _locks[key].unlock(); }
	bool TryLock(const char* key = nullptr) { if (!key) return _lock.try_lock(); else return _locks[key].try_lock(); }

private:
	static std::shared_ptr<Task> _pinstance;

	bool _bRun = false;
	std::mutex _lock;
	std::map<const char *, std::mutex>_locks;
	std::vector<std::thread> _threads;
	std::list<std::function<void()>> _tasks;
};

std::shared_ptr<Task> Task::_pinstance = nullptr;