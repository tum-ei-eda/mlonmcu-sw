#include "polybench_wrapper.h"

int mlonmcu_init() { return 0; }
int mlonmcu_deinit() { return 0; }

int mlonmcu_run() {
    int   argc = 0;
    char *argv[1];
    return polybench_main(argc, argv);
}
int mlonmcu_check() { return 0; }
