#include "exit.h"
#include "printing.h"

void mlonmcu_exit(int status) {
    mlonmcu_printf("MLONMCU EXIT: %d\n", status);
#ifndef MLONMCU_TARGET_ARA
    exit(status);
#endif  // !MLONMCU_TARGET_ARA
}
