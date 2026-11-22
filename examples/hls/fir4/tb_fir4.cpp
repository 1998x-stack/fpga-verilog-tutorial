#include <cstdint>
#include <cstdio>
#include <cstdlib>
void fir4(std::int16_t sample, bool reset, std::int16_t *result);

// Independent reference state: different code structure to expose mistakes.
static std::int16_t golden(std::int16_t in, bool reset) {
    static std::int16_t history[3] = {0,0,0};
    if (reset) {
        history[0]=history[1]=history[2]=0;
        return 0;
    }
    std::int32_t sum = in;
    const int weights[3] = {2,2,1};
    for (int i=0;i<3;++i) sum += weights[i]*static_cast<std::int32_t>(history[i]);
    history[2]=history[1]; history[1]=history[0]; history[0]=in;
    return static_cast<std::int16_t>(sum/6);
}
static unsigned checks=0;
static void test(std::int16_t input,bool reset) {
    std::int16_t out=1234;
    fir4(input,reset,&out);
    const auto expected=golden(input,reset);
    if(out!=expected) {
        std::fprintf(stderr,"FAIL FIR input=%d reset=%d out=%d expected=%d at %u\n",
                     input,static_cast<int>(reset),out,expected,checks);
        std::exit(1);
    }
    ++checks;
}
int main() {
    test(0,true);
    const std::int16_t impulse[] = {600,0,0,0,0,0};
    for(auto x:impulse) test(x,false);
    test(0,true);
    for(int i=0;i<32;++i)test(32767,false);
    for(int i=0;i<32;++i)test(-32768,false);
    test(0,true);
    std::uint32_t state=0xC001D00Du;
    for(int i=0;i<1024;++i) {
        state=state*1664525u+1013904223u;
        const int val=static_cast<int>((state>>16)&65535u)-32768;
        test(static_cast<std::int16_t>(val),false);
    }
    std::printf("PASS FIR4 portable C++ reference (%u samples)\n",checks);
    return 0;
}
