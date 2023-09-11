#include "ml_interface.h"

#include "model.cc.h"

void mlonmcu_init() {
  model_init();
}

void mlonmcu_deinit() {}

void mlonmcu_run() {
  size_t remaining = NUM_RUNS;
  while (remaining) {
    model_invoke();
    remaining--;
  }
}

void mlonmcu_check() {
  size_t input_num = 0;
  while (mlif_request_input(model_input_ptr(input_num), model_input_size(input_num))) {
    if (input_num == model_inputs() - 1) {
      model_invoke();
      for (size_t i = 0; i < model_outputs(); i++) {
        mlif_handle_result(model_output_ptr(i), model_output_size(i));
      }
      input_num = 0;
    } else {
      input_num++;
    }
  }
}
