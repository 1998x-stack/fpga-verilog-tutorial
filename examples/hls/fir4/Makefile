CXX ?= c++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra -Wno-unknown-pragmas -pedantic
.PHONY: test clean
test: fir4_test
	./fir4_test
fir4_test: fir4.cpp tb_fir4.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@
clean:
	rm -f fir4_test
