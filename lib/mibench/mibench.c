#include "mibench_wrapper.h"

int mlonmcu_init() {return 0;}
int mlonmcu_deinit() {return 0;}

int mlonmcu_run() {
    return mibench_main();
}

int mlonmcu_check() {return 0;}
