#include "ml_interface.h"
#include "target.h"
#include <stdio.h>

void init_target();
void deinit_target();

int main() {
  init_target();
  printf("Program start.\n");
  start_timer();
  mlif_run();
  stop_timer();
  printf("Program finish.\n");
  deinit_target();
  return 0;
}
