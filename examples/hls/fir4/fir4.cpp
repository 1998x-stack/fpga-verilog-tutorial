#include <cstdint>
// Four-tap FIR. One invocation consumes one sample; no native stream backpressure.
// The requested II=1 is only a directive; check the actual HLS scheduling report.
void fir4(std::int16_t sample, bool reset, std::int16_t *result) {
#pragma HLS PIPELINE II=1
    static std::int16_t z1 = 0, z2 = 0, z3 = 0;
    if (reset) {
        z1 = 0; z2 = 0; z3 = 0;
        *result = 0;
    } else {
        const std::int32_t sum =
            static_cast<std::int32_t>(sample) +
            2 * static_cast<std::int32_t>(z1) +
            2 * static_cast<std::int32_t>(z2) +
            static_cast<std::int32_t>(z3);
        *result = static_cast<std::int16_t>(sum / 6); // truncation toward zero
        z3 = z2; z2 = z1; z1 = sample;
    }
}
