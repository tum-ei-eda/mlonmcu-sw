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
    DTYPE a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8;

    for (size_t i = 0; i < ITER; ++i) {
        // Large, predictable basic block
        a = a + b;
        b = b ^ c;
        c = c * d;
        d = d + e;
        e = e ^ f;
        f = f * g;
        g = g + h;
        h = h ^ a;

        a = a + c;
        b = b * d;
        c = c + e;
        d = d ^ f;
        e = e * g;
        f = f + h;
        g = g ^ a;
        h = h * b;

        a = a + b + c + d + e + f + g + h;  // Prevent full common subexpression elimination
    }

    // Prevent compiler from optimizing away
    sink = a + b + c + d + e + f + g + h;
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
