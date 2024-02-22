/**********************************************************************
 *
 * Filename:    main.c
 *
 * Description: A simple test program for the CRC implementations.
 *
 * Notes:       To test a different CRC standard, modify crc.h.
 *
 *
 * Copyright (c) 2000 by Michael Barr.  This software is placed into
 * the public domain and may be used for any purpose.  However, this
 * notice must not be changed or removed and no warranty is either
 * expressed or implied by its publication or distribution.
 **********************************************************************/

#include <stdio.h>
#include <string.h>

#include "crc.h"

#ifndef SLOW
#define SLOW 1
#endif
#ifndef FAST
#define FAST 1
#endif

#if SLOW
static crc result_slow;
#endif // SLOW
#if FAST
static crc result_fast;
#endif // FAST


int mlonmcu_init() {
#if FAST
	crcInit();
#endif // SLOW
  return 0;
}

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
	unsigned char  test[] = "123456789";


#if SLOW
	/*
	 * Compute the CRC of the test message, slowly.
	 */
	result_slow = crcSlow(test, strlen(test));
#endif // SLOW

#if FAST
	/*
	 * Compute the CRC of the test message, more efficiently.
	 */
	result_fast = crcFast(test, strlen(test));
#endif // FAST
  return 0;
}

int mlonmcu_check() {
	/*
	 * Print the check value for the selected CRC algorithm.
	 */
	printf("The check value for the %s standard is 0x%X\n", CRC_NAME, CHECK_VALUE);
#if SLOW
	printf("The crcSlow() of \"123456789\" is 0x%X\n", result_slow);
#endif // SLOW
#if FAST
	printf("The crcFast() of \"123456789\" is 0x%X\n", result_fast);
#endif // FAST
  return 0;
}
