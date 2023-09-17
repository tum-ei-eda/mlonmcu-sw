#include "taclebench_wrapper.h"

int mlonmcu_init() {}
int mlonmcu_deinit() {}

int mlonmcu_run() {
    int ret = taclebench_main();
    return ret;
}
