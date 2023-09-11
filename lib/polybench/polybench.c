#include "polybench_wrapper.h"

int mlonmcu_init() {}
int mlonmcu_deinit() {}

int mlonmcu_run() {
    int   argc = 0;
    char *argv[1];
    return polybench_main(argc, argv);
}
int mlonmcu_check() {}
