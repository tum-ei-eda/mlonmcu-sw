/* See LICENSE of license details. */

#include <unistd.h>
#include "platform.h"

extern volatile uint32_t tohost;
extern volatile uint32_t fromhost;

void __wrap__exit(int code)
{
//volatile uint32_t* leds = (uint32_t*) (GPIO_BASE_ADDR + GPIO_OUT_OFFSET);
  const char message[] = "\nProgam has exited with code:";
//*leds = (~(code));

  write(STDERR_FILENO, message, sizeof(message) - 1);
  write_hex(STDERR_FILENO, code);
  write(STDERR_FILENO, "\n", 1);
  tohost = code+1;
  write(STDERR_FILENO, "\x04", 1);
  for (;;);
}
