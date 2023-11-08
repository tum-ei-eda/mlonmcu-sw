#include "taclebench_wrapper.h"
#include "exit.h"

int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}

int ret = 0;

int mlonmcu_run() {
  ret = taclebench_main();
  return 0;
}
int mlonmcu_check() {
  if (ret < 0) {
      return EXIT_MLIF_MISSMATCH;
  }
  return 0;
}
