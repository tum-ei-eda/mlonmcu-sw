#include "exit.h"
#include "printing.h"

void mlonmcu_exit(int status) {
    mlonmcu_printf("MLONMCU EXIT: %d\n", status);
    exit(status);
}
