#include "taclebench_wrapper.h"

int mlonmcu_init() {}
int mlonmcu_deinit() {}

int mlonmcu_run() {
    return taclebench_main();
}
int mlonmcu_check() {}
