// IsInRangeTest.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include "pch.h"
#include <iostream>
//#include "IsInRange.h"

#include <list>
#include <vector>
#include <functional>
#include <thread>

#include <future>
#include <chrono>

//#include <Windows.h>

#include "../Task/Task/Public/Task.h"

std::mutex G_Lock;

int Add(int a, int b, int c) {
	//std::this_thread::sleep_for(std::chrono::seconds(1));
	return a + b + c;
}

class T {
public:
	T() {
		_i = new int(0);
	};
	virtual ~T() {
		if (_i) delete _i;
	};
	T(T && r) {
		std::cout << "move construct" << std::endl;
		_i = r._i;
		r._i = nullptr;
	}
	/*T& operator=(T && r) {
		std::cout << "move assign" << std::endl;
		_i = r._i;
		r._i = nullptr;
	}*/
	T(const T & l) {
		std::cout << "copy construct" << std::endl;
		_i = new int(*l._i);
	}
	//T& operator=(const T & l) {
	//	std::cout << "copy assign" << std::endl;
	//	_i = new int(*l._i);
	//}

	int * _i = nullptr;
};

using std::min;

int mmin(int a, int b) noexcept(noexcept(std::min(a, b)))
{
	return std::min(a, b);
}

template<typename T>
using uptr = std::unique_ptr<T>;
template<typename T>
using sptr = std::shared_ptr<T>;
template<typename T>
using wptr = std::weak_ptr<T>;

class a 
{
public:
	a()
	{
		auto p = std::make_unique<class C>();
		_p = std::make_shared<class C>(p);
	}
private:
	wptr<class C> _p;
};

class C
{
public:
	C()
	{
		std::cout << "obj C spawned" << std::endl;
	}
};

int main()
{
	auto aaaaa = std::make_shared<a>();

	//auto a = T();
	//std::cout
	//	<< a._i
	//	<< std::endl;
	//auto b = a;
	//auto c = std::move(a);

	//std::cout
	//	<< a._i
	//	<< std::endl
	//	<< b._i
	//	<< std::endl
	//	<< c._i
	//	<< std::endl;

	////std::cout << Do<int(int, int, int)>(Add, 1, 2, 3) << std::endl;
	//int i = 0;
	//if (false)
	//{
	//	auto task = Task::GetInstance();
	//	Task::Destroy();
	//	std::mutex m;
	//	while (true)
	//	{
	//		int a = rand(), b = rand();
	//		task->Lock();
	//		//for (auto j = 0; j < 10; j++)
	//		{
	//			task->AddTask<int>(Add, a, b, 0)->OnValid([&task, a, b, &m](auto& f) {
	//				std::cout << "thread id = " << std::this_thread::get_id() << "\t";
	//				std::cout << a << "+" << b << "=" << f.Get() << " right = " << a + b << std::endl;
	//			});
	//		}
	//		task->Unlock();
	//		i++;
	//		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	//	}

	//	auto f = std::async(std::launch::async, Add, 1, 2, 3);
	//}
	return 0;
}

// 运行程序: Ctrl + F5 或调试 >“开始执行(不调试)”菜单
// 调试程序: F5 或调试 >“开始调试”菜单

// 入门提示: 
//   1. 使用解决方案资源管理器窗口添加/管理文件
//   2. 使用团队资源管理器窗口连接到源代码管理
//   3. 使用输出窗口查看生成输出和其他消息
//   4. 使用错误列表窗口查看错误
//   5. 转到“项目”>“添加新项”以创建新的代码文件，或转到“项目”>“添加现有项”以将现有代码文件添加到项目
//   6. 将来，若要再次打开此项目，请转到“文件”>“打开”>“项目”并选择 .sln 文件