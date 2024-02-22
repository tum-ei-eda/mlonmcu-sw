#include <stdio.h>
#include <string.h>
#include "printing.h"

int aes_main (void);

static int result = -1;

int mlonmcu_init() {
  return 0;
}

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
  result = aes_main();
  return 0;
}

int mlonmcu_check() {
  mlonmcu_printf ("result=%d\n", result);
  return !(result == 0);
}
