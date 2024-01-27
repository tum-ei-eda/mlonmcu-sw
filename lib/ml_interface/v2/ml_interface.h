#ifndef TARGETLIB_ML_INTERFACE_H
#define TARGETLIB_ML_INTERFACE_H

#include <stddef.h>
#include <stdbool.h>

#ifndef NUM_RUNS
#define NUM_RUNS 1
#endif /* NUM_RUNS */

#ifndef BATCH_SIZE
#define BATCH_SIZE 0
#endif /* BATCH_SIZE */


#ifdef __cplusplus
extern "C" {
#endif
// These can be overridden by use code.

// Provides input data for the model.
int mlif_request_inputs(size_t batch_idx, bool *new_);
// Is called when the output data is available.
int mlif_handle_results(size_t batch_idx);

// Callback for any preprocessing on the input data. Responsible for copying the data.
int mlif_process_inputs(size_t batch_idx, bool *new_);
// Callback for any postprocessing on the output data.
int mlif_process_outputs(size_t batch_idx);

int mlif_num_inputs();
int mlif_num_outputs();
void *mlif_input_ptr(int i);
int mlif_input_sz(int i);
void *mlif_output_ptr(int i);
int mlif_output_sz(int i);
int mlif_invoke();
int mlif_init();

extern const int num;

#ifdef __cplusplus
}
#endif

#endif
