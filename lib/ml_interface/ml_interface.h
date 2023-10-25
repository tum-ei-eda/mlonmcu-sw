#ifndef TARGETLIB_ML_INTERFACE_H
#define TARGETLIB_ML_INTERFACE_H

#include <stddef.h>
#include <stdbool.h>

#ifndef NUM_RUNS
#define NUM_RUNS 1
#endif /* NUM_RUNS */

#ifdef __cplusplus
extern "C" {
#endif

// This runs the ML model using the callbacks above.
// The default implementation will run with garbage data.
void mlif_run();

// These can be overridden by use code.

// Provides input data for the model. The default implementation retrieves input from
// the global variables below and fills the model input with mlif_process_input.
bool mlif_request_input(void *model_input_ptr, size_t model_input_sz);
// Is called when the output data is available. The default implementation
void mlif_handle_result(void *model_output_ptr, size_t model_output_sz);

// Callback for any preprocessing on the input data. Responsible for copying the data.
void mlif_process_input(const void *in_data, size_t in_size, void *model_input_ptr, size_t model_input_sz);
// Callback for any postprocessing on the output data. The default implementation prints
// the output and verifies consistency with the expected output.
void mlif_process_output(void *model_output_ptr, size_t model_output_sz, const void *expected_out_data, size_t expected_out_size);

extern const int num_data_buffers_in;
extern const int num_data_buffers_out;
extern const unsigned char *const data_buffers_in[];
extern const unsigned char *const data_buffers_out[];
extern const size_t data_size_in[];
extern const size_t data_size_out[];

extern const int num;

#ifdef __cplusplus
}
#endif

#endif
/*
const int num_data_buffers_in = 4;
const int num_data_buffers_out = 4;
const unsigned char data_buffer_in_0_0[] = {0x00, 0x00, 0x00, 0x00, };
const unsigned char data_buffer_in_1_0[] = {0xc3, 0xf5, 0xc8, 0x3f, };
const unsigned char data_buffer_in_2_0[] = {0xc3, 0xf5, 0x48, 0x40, };
const unsigned char data_buffer_in_3_0[] = {0x52, 0xb8, 0x96, 0x40, };
const unsigned char data_buffer_out_0_0[] = {0x30, 0x3b, 0x03, 0x3d, };
const unsigned char data_buffer_out_1_0[] = {0x19, 0xc1, 0x73, 0x3f, };
const unsigned char data_buffer_out_2_0[] = {0x30, 0x08, 0x40, 0xbd, };
const unsigned char data_buffer_out_3_0[] = {0x54, 0xb4, 0x81, 0xbf, };
const unsigned char *const data_buffers_in[] = {data_buffer_in_0_0, data_buffer_in_1_0, data_buffer_in_2_0, data_buffer_in_3_0, };
const unsigned char *const data_buffers_out[] = {data_buffer_out_0_0, data_buffer_out_1_0, data_buffer_out_2_0, data_buffer_out_3_0, };
const size_t data_size_in[] = {sizeof(data_buffer_in_0_0), sizeof(data_buffer_in_1_0), sizeof(data_buffer_in_2_0), sizeof(data_buffer_in_3_0), };
const size_t data_size_out[] = {sizeof(data_buffer_out_0_0), sizeof(data_buffer_out_1_0), sizeof(data_buffer_out_2_0), sizeof(data_buffer_out_3_0), };*/