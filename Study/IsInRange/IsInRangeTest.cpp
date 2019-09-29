// IsInRangeTest.cpp : ���ļ����� "main" ����������ִ�н��ڴ˴���ʼ��������
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

// ���г���: Ctrl + F5 ����� >����ʼִ��(������)���˵�
// ���Գ���: F5 ����� >����ʼ���ԡ��˵�

// ������ʾ: 
//   1. ʹ�ý��������Դ�������������/�����ļ�
//   2. ʹ���Ŷ���Դ�������������ӵ�Դ�������
//   3. ʹ��������ڲ鿴���������������Ϣ
//   4. ʹ�ô����б��ڲ鿴����
//   5. ת������Ŀ��>���������Դ����µĴ����ļ�����ת������Ŀ��>�����������Խ����д����ļ���ӵ���Ŀ
//   6. ��������Ҫ�ٴδ򿪴���Ŀ����ת�����ļ���>���򿪡�>����Ŀ����ѡ�� .sln �ļ�