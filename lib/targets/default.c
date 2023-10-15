#include <stdint.h>

__attribute__((weak)) void init_target() {}
__attribute__((weak)) void deinit_target() {}
__attribute__((weak)) void start_timer() {}
__attribute__((weak)) void stop_timer() {}
__attribute__((weak)) uint64_t target_cycles() { return 0; }
__attribute__((weak)) uint64_t target_instructions() { return 0; }
