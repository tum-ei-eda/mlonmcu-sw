#include <stdlib.h>
#include <memory.h>
#include "ml_interface.h"

int mlif_process_inputs(size_t batch_idx, bool *new_) {
  for (size_t input_idx = 0; input_idx < mlif_num_inputs(); input_idx++) {
    memset(mlif_input_ptr(input_idx), 0, mlif_input_sz(input_idx));
    *new_ = true;
  }
  return 0;
}
