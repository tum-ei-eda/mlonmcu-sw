#include <stdint.h>

#include "test.h"

int32_t to_upper(size_t n, char* c)
{
    for (size_t i = 0; i < n; i++)
        c[i] += (c[i] >= 'a' && c[i] <= 'z') ? ('A'-'a') : 0;
}

int32_t add8(size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n])
{
    for (size_t i = 0; i < n; i++)
        d[i] = a[i] + b[i];
}
int32_t add16(size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n])
{
    for (size_t i = 0; i < n; i++)
        d[i] = a[i] + b[i];
}

int32_t dot8(size_t n, int8_t a[n], int8_t b[n])
{
    uint32_t acc = 0;
    for (size_t i = 0; i < n; i++)
        acc += a[i] * b[i];

    return acc;
}
int32_t dot16(size_t n, int16_t a[n], int16_t b[n])
{
    uint32_t acc = 0;
    for (size_t i = 0; i < n; i++)
        acc += a[i] * b[i];

    return acc;
}

int32_t saxpy8(size_t n, int8_t d[restrict n], int8_t x[n], int8_t y[n], int8_t a)
{
    for (size_t i = 0; i < n; i++)
        d[i] = a * x[i] + y[i];
}
int32_t saxpy16(size_t n, int16_t d[restrict n], int16_t x[n], int16_t y[n], int16_t a)
{
    for (size_t i = 0; i < n; i++)
        d[i] = a * x[i] + y[i];
}

int32_t matmul8 (size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n])
{
    for (size_t a_y = 0; a_y < n; a_y++)
    {
        for (size_t b_y = 0; b_y < n; b_y++)
        {
            for (size_t i = 0; i < n; i++)
                d[a_y * n + i] += a[a_y * n + b_y] * b[b_y * n + i];
        }
    }
    return 0;
}

int32_t matmul16 (size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n])
{
    for (size_t a_y = 0; a_y < n; a_y++)
    {
        for (size_t b_y = 0; b_y < n; b_y++)
        {
            for (size_t i = 0; i < n; i++)
                d[a_y * n + i] += a[a_y * n + b_y] * b[b_y * n + i];
        }
    }
}

int32_t transposed_matmul8 (size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n])
{
    for (size_t a_y = 0; a_y < n; a_y++)
    {
        for (size_t b_y = 0; b_y < n; b_y++)
        {
            for (size_t i = 0; i < n; i++)
                d[a_y * n + i] += a[a_y * n + b_y] * b[i * n + b_y];
        }
    }
    return 0;
}

int32_t transposed_matmul16 (size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n])
{
    for (size_t a_y = 0; a_y < n; a_y++)
    {
        for (size_t b_y = 0; b_y < n; b_y++)
        {
            for (size_t i = 0; i < n; i++)
                d[a_y * n + i] += a[a_y * n + b_y] * b[i * n + b_y];
        }
    }
}

int32_t matmul8_ (size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            for (size_t i = 0; i < n; i++)
                d[y * n + x] += a[y * n + i] * b[i * n + x];
        }
    }
    return 0;
}

int32_t matmul16_ (size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            for (size_t i = 0; i < n; i++)
                d[y * n + x] += a[y * n + i] * b[i * n + x];
        }
    }
}

int32_t transposed_matmul8_ (size_t n, int8_t d[restrict n], int8_t a[n], int8_t b[n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            for (size_t i = 0; i < n; i++)
                d[y * n + x] += a[y * n + i] * b[x * n + i];
        }
    }
}

int32_t transposed_matmul16_ (size_t n, int16_t d[restrict n], int16_t a[n], int16_t b[n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            for (size_t i = 0; i < n; i++)
                d[y * n + x] += a[y * n + i] * b[x * n + i];
        }
    }
}

int32_t matmulT8 (size_t n, int8_t d[restrict n*n], int8_t a[n*n], int8_t b[n*n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            d[y * n + x] = dot8(n, &a[y*n], &b[x*n]);
        }
    }
}

int32_t matmulT16 (size_t n, int16_t d[restrict n*n], int16_t a[n*n], int16_t b[n*n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            d[y * n + x] = dot16(n, &a[y*n], &b[x*n]);
        }
    }
}
