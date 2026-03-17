#include <stdint.h>
#include "linux_time.h"

void init_target() {}
void deinit_target() {}

uint64_t target_cycles() {
  return linux_cycles();
}


uint64_t target_instructions() {
  return 0;
}

uint64_t target_time() {
  return linux_time_us();
}
