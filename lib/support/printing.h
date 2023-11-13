#ifndef SUPPORT_PRINTING_H
#define SUPPORT_PRINTING_H

#include "target.h"
// void mlonmcu_printf(const char* format, ...);
#define mlonmcu_printf target_printf

#ifdef _DEBUG
#define DBGPRINTF(format, ...) mlonmcu_printf(format, ##__VA_ARGS__)
#else
#define DBGPRINTF(format, ...)
#endif

#endif
