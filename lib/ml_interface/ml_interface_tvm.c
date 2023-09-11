#include "ml_interface.h"
#include "tvm_wrapper.h"

void mlonmcu_init() {
  TVMWrap_Init();
}
void mlonmcu_deinit() {}

void mlonmcu_run() {
  size_t remaining = NUM_RUNS;
  while (remaining) {
    TVMWrap_Run();
    remaining--;
  }
}

void mlonmcu_check() {
  size_t input_num = 0;
  while (mlif_request_input(TVMWrap_GetInputPtr(input_num), TVMWrap_GetInputSize(input_num))) {
    if (input_num == TVMWrap_GetNumInputs() - 1) {
      TVMWrap_Run();
      for (size_t i = 0; i < TVMWrap_GetNumOutputs(); i++) {
        mlif_handle_result(TVMWrap_GetOutputPtr(i), TVMWrap_GetOutputSize(i));
      }
      input_num = 0;
    } else {
      input_num++;
    }
  }
}
