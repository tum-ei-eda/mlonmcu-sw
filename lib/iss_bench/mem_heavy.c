#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

#ifndef ITER
#define ITER 100000000  // Number of loop iterations
#endif  // ITER

#ifndef DTYPE
#define DTYPE uint32_t
#endif  // DTYPE

#ifndef ARRAY_SIZE
#define ARRAY_SIZE (1024 * 1024)
#endif  // ARRAY_SIZE

#define MAX(a,b) (((a)>(b))?(a):(b))

volatile DTYPE sink;  // Prevent optimization

int do_work() {
    DTYPE *data = malloc(sizeof(DTYPE) * ARRAY_SIZE);
    if (!data) return 1;

    // Initialize array
    for (size_t i = 0; i < ARRAY_SIZE; ++i) {
        data[i] = i ^ 0xDEADBEEF;
    }

    // Memory-heavy access pattern
    volatile uint64_t sum = 0;
    for (size_t j = 0; j < MAX(1, ITER / ARRAY_SIZE); ++j) {
        for (DTYPE i = 0; i < ARRAY_SIZE; ++i) {
            sum += data[i];
            data[i] ^= (sum & 0xFF); // modify to trigger stores
        }
    }

    sink = sum;
    free(data);
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
