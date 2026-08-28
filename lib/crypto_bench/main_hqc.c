#include <stdio.h>
#include <string.h>

#include "api.h"
#include "parameters.h"

#include "printing.h"

static unsigned char pk[PUBLIC_KEY_BYTES];
static unsigned char sk[SECRET_KEY_BYTES];
static unsigned char ct[CIPHERTEXT_BYTES];
static unsigned char key1[SHARED_SECRET_BYTES];
static unsigned char key2[SHARED_SECRET_BYTES];

int mlonmcu_init() {
  mlonmcu_printf("\n");
  mlonmcu_printf("*********************\n");
  mlonmcu_printf("**** HQC-%d-%d ****\n", PARAM_SECURITY, PARAM_DFR_EXP);
  mlonmcu_printf("*********************\n");

  mlonmcu_printf("\n");
  mlonmcu_printf("N: %d   ", PARAM_N);
  mlonmcu_printf("N1: %d   ", PARAM_N1);
  mlonmcu_printf("N2: %d   ", PARAM_N2);
  mlonmcu_printf("OMEGA: %d   ", PARAM_OMEGA);
  mlonmcu_printf("OMEGA_R: %d   ", PARAM_OMEGA_R);
  mlonmcu_printf("Failure rate: 2^-%d   ", PARAM_DFR_EXP);
  mlonmcu_printf("Sec: %d bits", PARAM_SECURITY);
  mlonmcu_printf("\n");
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}
int mlonmcu_run() {
  crypto_kem_keypair(pk, sk);
  crypto_kem_enc(ct, key1, pk);
  crypto_kem_dec(key2, ct, sk);
  return 0;
}
int mlonmcu_check() {
  mlonmcu_printf("\n\nsecret1: ");
  for(int i = 0 ; i < SHARED_SECRET_BYTES ; ++i) printf("%x", key1[i]);

  mlonmcu_printf("\nsecret2: ");
  for(int i = 0 ; i < SHARED_SECRET_BYTES ; ++i) printf("%x", key2[i]);
  mlonmcu_printf("\n\n");
  return 0;
}
