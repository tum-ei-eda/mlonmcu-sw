#ifndef _UTILS_H_
#define _UTILS_H_

/**
 * @brief Write to CSR.
 * @param CSR register to write.
 * @param Value to write to CSR register.
 * @return void
 *
 * Function to handle CSR writes.
 *
 */
#define csrw(csr, value)  asm volatile ("csrw\t\t" #csr ", %0" : /* no output */ : "r" (value));

/**
 * @brief Read from CSR.
 * @param void
 * @return 32-bit unsigned int
 *
 * Function to handle CSR reads.
 *
 */
#define csrr(csr, value)  asm volatile ("csrr\t\t%0, " #csr "": "=r" (value));

#endif
