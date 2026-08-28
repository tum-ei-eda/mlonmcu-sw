#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "printing.h"

#include "params.h"
#include "decrypt.h"


// Buffers in .bss / .rodata
static unsigned char s[SYND_BYTES];                   // ciphertext (syndrome)
static unsigned char e[SYS_N/8];                      // error vector output
static const unsigned char sk[IRR_BYTES + PK_NROWS * PK_ROW_BYTES] = {0}; // dummy secret key

int mlonmcu_init() {
  memset(s, 0, sizeof(s));
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}
int mlonmcu_run() {
  int ret = decrypt(e, sk, s);
  // printf("decryption return = %d\n", ret);
  // TODO: check ret?
  return 0;
}
int mlonmcu_check() {
    // Lightweight correctness check
    unsigned long checksum = 0;
    for (size_t i = 0; i < sizeof(e); i++) checksum += e[i];

    printf("checksum(e) = %lu\n", checksum);
  return 0;
}
