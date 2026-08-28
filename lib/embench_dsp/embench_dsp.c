#include "boardsupport.h"
#include "exit.h"
#include <stdio.h>


int mlonmcu_init() {
  init_board();
  return 0;
}

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
  int result = test_main();  // TODO: split test_main into init + run + check or measure cycles via triggers!
  return result;
}
int mlonmcu_check() {
  return 0;
}
