#include <stdint.h>
#include <stddef.h>

#ifndef ITER
#define ITER 100000000  // Number of loop iterations
#endif  // ITER

#ifndef DTYPE
#define DTYPE uint64_t
#endif  // DTYPE

volatile DTYPE sink;  // Prevent optimization

int do_work() {
    volatile DTYPE acc = 0;
    for (size_t i = 0; i < ITER; ++i) {
        // Frequent unpredictable branches
        if (i & 1) acc += i;
        else acc ^= i;

        if (i % 3 == 0) acc += (i << 1);
        else acc -= (i >> 2);

        if (i % 5 == 0) acc ^= (i * 3);
        else acc += (i / 2);
    }
    sink = acc;
    return 0;
}


int mlonmcu_init() {
  return 0;
}

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
  return do_work();
}

int mlonmcu_check() {
  return 0;
}
