// iree_platform_overrides.h
#ifndef IREE_PLATFORM_OVERRIDES_H_
#define IREE_PLATFORM_OVERRIDES_H_

#define IREE_TIME_NOW_FN { return 0; }
#define IREE_WAIT_UNTIL_FN(ns) (true)
#define IREE_MEMORY_FLUSH_ICACHE(start, end) do { } while (0)

#endif  // IREE_PLATFORM_OVERRIDES_H_
