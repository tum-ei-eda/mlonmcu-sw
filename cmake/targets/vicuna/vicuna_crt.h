#ifndef _VICUNA_CRT_H
#define _VICUNA_CRT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>

#include "runtime.h"
#include "uart.h"

// TODO(fabianpedd): This is all very hacky and needs to be properly fixed at some point
#define printf uart_printf
// TODO(fabianpedd): For some reason the Newlib malloc/free on Vicuna are not working. Need to figure out why...
#define malloc vicuna_malloc
#define free vicuna_free

void *vicuna_malloc(size_t size);

void vicuna_free(void *ptr);

#ifdef __cplusplus
}
#endif

#endif /* _VICUNA_CRT_H */
