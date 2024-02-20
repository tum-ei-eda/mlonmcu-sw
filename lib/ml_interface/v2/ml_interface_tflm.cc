#include "ml_interface.h"

#include "model.cc.h"

#ifdef __cplusplus
extern "C"
#endif
int mlif_num_inputs() {
  return model_inputs();
}

#ifdef __cplusplus
extern "C"
#endif
int mlif_num_outputs() {
  return model_outputs();
}

#ifdef __cplusplus
extern "C"
#endif
void* mlif_input_ptr(int i) {
  return model_input_ptr(i);
}

#ifdef __cplusplus
extern "C"
#endif
void* mlif_output_ptr(int i) {
  return model_output_ptr(i);
}

#ifdef __cplusplus
extern "C"
#endif
int mlif_input_sz(int i) {
  return model_input_size(i);
}

#ifdef __cplusplus
extern "C"
#endif
int mlif_output_sz(int i) {
  return model_output_size(i);
}

#ifdef __cplusplus
extern "C"
#endif
int mlif_invoke() {
  return model_invoke();
}

#ifdef __cplusplus
extern "C"
#endif
int mlif_init() {
  return model_init();
}
