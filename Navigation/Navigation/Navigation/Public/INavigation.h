#pragma once

#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <memory>
#include <algorithm>
#include <queue>
#include <functional>

namespace NS_Navigation {

	template<typename M, typename D>
	class INavigation
	{
	public:
		using ptrM = std::shared_ptr<M>;
		using ptrD = std::shared_ptr<D>;
		//using Compare = typename std::greater<D>;

		struct Compare
		{
			/*bool operator()(const D & a, const D & b) {
				return a > b;
			}*/
			bool operator()(const std::shared_ptr<D> & a, const std::shared_ptr<D> & b) {
				return (*a) > (*b);
			}
		};

		virtual INavigation * Init(std::shared_ptr<M> & map) = 0;

		virtual std::shared_ptr<M> GetMap() = 0;

		virtual INavigation * AddOpen(std::priority_queue<std::shared_ptr<D>, std::vector<std::shared_ptr<D>>, INavigation<M, D>::Compare> & open, std::shared_ptr<D> & o) = 0;

		virtual INavigation * AddClose(std::unordered_set<int>& close, int index1, int index2 = -1) = 0;

		virtual bool IsInClose(std::unordered_set<int>& close, int index1, int index2 = -1) = 0;

		virtual int ExpectDistance(int index1, int index2) = 0;

		virtual int CalcuDistance(int index1, int index2, int dps, int speed) = 0;

		virtual INavigation * AddWallAttraction(std::vector<int> & path) = 0;

		virtual std::vector<int> Search(int sx, int sy, int ex, int ey, int dps, int speed, int duration = 0) = 0;

		virtual std::vector<int> FlagSearch(int sx, int sy, unsigned short flag, int dps, int speed, int duration = 0) = 0;

		virtual std::vector<int> MultiSearch(int sx, int sy, std::vector<std::pair<int, int>> & ends, int dps, int speed, int duration = 0) = 0;

		virtual std::vector<int> ResumeSearch(int searchId, int etime) = 0;
	};

}