#include "ml_interface.h"
#include "tvm_wrapper.h"


int mlif_num_inputs() {
  return TVMWrap_GetNumInputs();
}

int mlif_num_outputs() {
  return TVMWrap_GetNumOutputs();
}

void* mlif_input_ptr(int i) {
  return TVMWrap_GetInputPtr(i);
}

void* mlif_output_ptr(int i) {
  return TVMWrap_GetOutputPtr(i);
}

int mlif_input_sz(int i) {
  return TVMWrap_GetInputSize(i);
}

int mlif_output_sz(int i) {
  return TVMWrap_GetOutputSize(i);
}

int mlif_invoke() {
  return TVMWrap_Run();
}

int mlif_init() {
  return TVMWrap_Init();
}
