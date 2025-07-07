#include "exit.h"
#include "printing.h"

void mlonmcu_exit(int status) {
    mlonmcu_printf("MLONMCU EXIT: %d\n", status);
#if defined(MLONMCU_TARGET_ARA)
    // do nothing
#elif defined(MLONMCU_TARGET_VICUNA)
    asm volatile("jr x0"); // jump to address 0 (ends simulation)
#elif defined(MLONMCU_TARGET_VICUNA2)
    exit(status);  // TODO: ?
#else
    exit(status);
#endif  // !MLONMCU_TARGET_ARA
}
