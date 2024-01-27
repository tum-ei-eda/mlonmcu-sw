#include "ml_interface.h"
#include "printing.h"

#include <string.h>
#include <stdlib.h>

__attribute__((weak)) int mlif_request_inputs(size_t batch_idx, bool *new_) {
  int ret = mlif_process_inputs(batch_idx, new_);
  return ret;
}

__attribute__((weak)) int mlif_handle_results(size_t batch_idx) {
  int ret = mlif_process_outputs(batch_idx);
  return ret;
}

int mlonmcu_init() {
  return mlif_init();
}
int mlonmcu_deinit() {return 0;}

int mlonmcu_run() {
  size_t remaining = NUM_RUNS;
  int ret = 0;
  while (remaining) {
    ret = mlif_invoke();
    if (ret) {
      return ret;
    }
    remaining--;
  }
  return ret;
}

int mlonmcu_check() {
  // size_t batch_size = mlif_get_batch_size();
  size_t batch_size = BATCH_SIZE;
  int ret = 0;
  bool new_ = false;
  for (size_t batch_idx = 0; batch_idx < batch_size; batch_idx++) {
    ret = mlif_request_inputs(batch_idx, &new_);
    if (ret) {
      return ret;
    }
    if (!new_) {
      break;
    }
    ret = mlif_invoke();
    if (ret) {
      return ret;
    }
    ret = mlif_handle_results(batch_idx);
    if (ret) {
      return ret;
    }
  }
  return ret;
}
