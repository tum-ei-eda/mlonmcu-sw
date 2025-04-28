#include "ml_interface.h"
#include "iree_wrapper.h"


int mlif_num_inputs() {
  return IREE_GetNumInputs();
}

int mlif_num_outputs() {
  return IREE_GetNumOutputs();
}

void* mlif_input_ptr(int i) {
  return IREE_GetInputPtr(i);
}

void* mlif_output_ptr(int i) {
  return IREE_GetOutputPtr(i);
}

int mlif_input_sz(int i) {
  return IREE_GetInputSize(i);
}

int mlif_output_sz(int i) {
  return IREE_GetOutputSize(i);
}

int mlif_invoke() {
  return IREE_Run();
}

int mlif_init() {
  return IREE_Init();
}
