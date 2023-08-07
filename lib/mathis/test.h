#ifndef LIB_MATHIS_TEST_H
#define LIB_MATHIS_TEST_H

#include <stdint.h>
#include <stddef.h>

int32_t to_upper(size_t n, char* c);
int32_t add8(size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n]);
int32_t add16(size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n]);
int32_t dot8(size_t n, int8_t a[n], int8_t b[n]);
int32_t dot16(size_t n, int16_t a[n], int16_t b[n]);
int32_t saxpy8(size_t n, int8_t d[restrict n], int8_t x[n], int8_t y[n], int8_t a);
int32_t saxpy16(size_t n, int16_t d[restrict n], int16_t x[n], int16_t y[n], int16_t a);
int32_t matmul8 (size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n]);
int32_t matmul16 (size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n]);

#endif  // LIB_MATHIS_TEST_H