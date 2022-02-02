#include "ml_interface.h"

void init_target();
void deinit_target();

int main() {
  init_target();
  mlif_run();
  deinit_target();
}
