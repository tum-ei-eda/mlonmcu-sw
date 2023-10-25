#include "ml_interface.h"
#include <stdio.h>

void init_target();
void deinit_target();

int main() {
  init_target();
  mlif_run();
  printf("Done");
  deinit_target();
}
