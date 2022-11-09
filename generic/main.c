#include "ml_interface.h"
#include <stdio.h>

void init_target();
void deinit_target();

int main() {
  printf("Program start.\n");
  init_target();
  mlif_run();
  deinit_target();
  printf("Program finish.\n");
  return 0;
}
