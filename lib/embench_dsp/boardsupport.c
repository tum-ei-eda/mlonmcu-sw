#include <stdint.h>
#include "boardsupport.h"
#include "target.h"


void
init_board ()
{}

uint64_t start = 0;
uint64_t end = 0;

void __attribute__ ((noinline))
start_trigger () {
  start = target_cycles();
}

void __attribute__ ((noinline))
stop_trigger () {
  end = target_cycles();
}

int __attribute__ ((noinline))
get_ccnt ()
{
  return end - start;
}
