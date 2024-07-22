#include <stdint.h>
#include <unistd.h>
#include <sys/time.h>

#ifdef _WIN32
#include <intrin.h>
#else
#include <x86intrin.h>
#endif

// TODO: move to
// #include "time_utils.h"

void init_target() {}
void deinit_target() {}

uint64_t target_cycles() {
  return __rdtsc();
}

uint64_t target_instructions() {
  return 0;
}

uint64_t target_time() {
  struct timeval now;
  gettimeofday(&now, NULL);
  uint64_t usecs = ((now.tv_sec * 1000000) + now.tv_usec);
  return usecs;
}
