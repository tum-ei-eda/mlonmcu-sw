#include "exit.h"

void mlonmcu_exit(int status) {
    printf("MLONMCU EXIT: %d\n", status);
    exit(status);
}
