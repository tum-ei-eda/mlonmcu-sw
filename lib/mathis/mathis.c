#include <stdint.h>
#include "test.h"

char array1[SIZE * ELEM_SIZE / 8];
char array2[SIZE * ELEM_SIZE / 8];
char array3[SIZE * ELEM_SIZE / 8];

int mlonmcu_init() {
    return 0;
}

int mlonmcu_deinit() {
    return 0;
}

int mlonmcu_run() {
    int32_t ret = -1;
#if NARGS == 1
    ret = FUNCTION(N);
#elif NARGS == 2
    ret = FUNCTION(N, array1);
#elif NARGS == 3
    ret = FUNCTION(N, array1, array2);
#elif NARGS == 4
    ret = FUNCTION(N, array1, array2, array3);
#elif NARGS == 5
    ret = FUNCTION(N, array1, array2, array3, 42);
#endif  // NARGS
    return ret != 0;
}

int mlonmcu_check() {
    return 0;
}
