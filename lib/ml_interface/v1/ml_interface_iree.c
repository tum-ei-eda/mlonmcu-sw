#include "ml_interface.h"
#include "iree_wrapper.h"
#include "printing.h"

int mlonmcu_init() {
  return IREE_Init();
}
int mlonmcu_deinit() {
  return IREE_Deinit();
}

int mlonmcu_run() {
  size_t remaining = NUM_RUNS;
  while (remaining) {
    int ret = IREE_Run();
    if (ret) {
      return ret;
    }
    remaining--;
  }
  return 0;
}

int mlonmcu_check() {
  size_t input_num = 0;
  int ret = 0;
  bool new_;
  while (true) {
    ret = mlif_request_input(IREE_GetInputPtr(input_num), IREE_GetInputSize(input_num), &new_);
    if (ret) {
      return ret;
    }
    if (!new_) {
      break;
    }
    if (input_num == IREE_GetNumInputs() - 1) {
      ret = IREE_Run();
      if (ret) {
        return ret;
      }
      for (size_t i = 0; i < IREE_GetNumOutputs(); i++) {
        ret = mlif_handle_result(IREE_GetOutputPtr(i), IREE_GetOutputSize(i));
        if (ret) {
          return ret;
        }
      }
      input_num = 0;
    } else {
      input_num++;
    }
  }
  return ret;
}
