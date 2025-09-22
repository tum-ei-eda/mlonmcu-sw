#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "printing.h"

#include "params.h"
#include "operations.h"

// int crypto_kem_keypair(unsigned char *pk, unsigned char *sk);

// Place PK and SK in .bss (static) to avoid stack overflow
static unsigned char pk[PK_NROWS * PK_ROW_BYTES];       // public key
static unsigned char sk[IRR_BYTES + COND_BYTES + SYS_N/8 + 32]; // secret key


int mlonmcu_init() {
    memset(pk, 0, sizeof(pk));
    memset(sk, 0, sizeof(sk));
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}
int mlonmcu_run() {
  int ret = crypto_kem_keypair(pk, sk);
  // printf("crypto_kem_keypair return = %d\n", ret);
  // TODO: check ret?
  return 0;
}
int mlonmcu_check() {
  // Lightweight checksum instead of printing full keys
  unsigned long pk_sum = 0, sk_sum = 0;
  for (size_t i = 0; i < sizeof(pk); i++) pk_sum += pk[i];
  for (size_t i = 0; i < sizeof(sk); i++) sk_sum += sk[i];

  printf("checksum(pk) = %lu\n", pk_sum);
  printf("checksum(sk) = %lu\n", sk_sum);
  return 0;
}
