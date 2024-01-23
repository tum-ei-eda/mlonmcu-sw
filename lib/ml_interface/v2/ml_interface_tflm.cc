#include "ml_interface.h"

#include "model.cc.h"

#ifdef __cplusplus
extern "C"
#endif
int mlonmcu_init() {
  return model_init();
}

#ifdef __cplusplus
extern "C"
#endif
int mlonmcu_deinit() {
  return 0;
}

#ifdef __cplusplus
extern "C"
#endif
int mlonmcu_run() {
  size_t remaining = NUM_RUNS;
  int ret;
  while (remaining) {
    ret = model_invoke();
    if (ret) {
      return ret;
    }
    remaining--;
  }
  return ret;
}

#ifdef __cplusplus
extern "C"
#endif
int mlonmcu_check() {
  size_t input_num = 0;
  int ret;
  bool new_;
  while (true) {
    ret = mlif_request_input(model_input_ptr(input_num), model_input_size(input_num), &new_);
    if (ret) {
      return ret;
    }
    if (!new_) {
      break;
    }
    if (input_num == model_inputs() - 1) {
      ret = model_invoke();
      if (ret) {
        return ret;
      }
      for (size_t i = 0; i < model_outputs(); i++) {
        ret = mlif_handle_result(model_output_ptr(i), model_output_size(i));
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
