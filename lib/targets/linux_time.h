#ifndef TARGETLIB_LINUX_TIME_H
#define TARGETLIB_LINUX_TIME_H

#include <unistd.h>

#define USE_WALLCLOCK_TIME
#include <sys/time.h>
#ifdef USE_WALLCLOCK_TIME
#else
#include <time.h>
#endif

#include <stdio.h>
#include <stdint.h>

#if defined(MLONMCU_TARGET_HOST_X86)
#ifdef _WIN32
#include <intrin.h>
#else
#include <x86intrin.h>
#endif
#endif

// #include "exit.h"

static inline uint64_t linux_cycles() {
#if defined(MLONMCU_TARGET_HOST_X86)
  return __rdtsc();
#else
  return 0;
#endif
}

static inline float linux_time(void) {
#ifdef USE_WALLCLOCK_TIME
    struct timeval now;
    if (gettimeofday(&now, NULL) != 0) {
        perror("gettimeofday failed");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    uint64_t elapsed = now.tv_sec + now.tv_usec / 1e6;
#else
    struct timespec tick;
    if (clock_gettime(CLOCK_MONOTONIC, &tick) != 0) {
        perror("clock_gettime");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    float elapsed = tick.tv_sec + tick.tv_nsec / 1e9;
#endif
    return elapsed;
}

static inline uint64_t linux_time_ns(void) {
#ifdef USE_WALLCLOCK_TIME
    struct timeval now;
    if (gettimeofday(&now, NULL) != 0) {
        perror("gettimeofday failed");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    uint64_t elapsed_ns = (now.tv_sec * 1e9) + now.tv_usec * 1e3;
#else
    struct timespec tick;
    if (clock_gettime(CLOCK_MONOTONIC, &tick) != 0) {
        perror("clock_gettime");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    uint64_t elapsed_ns = tick.tv_sec * 1e9 + tick.tv_nsec;
#endif
    return elapsed_ns;
}

static inline uint64_t linux_time_us(void) {
#ifdef USE_WALLCLOCK_TIME
    struct timeval now;
    if (gettimeofday(&now, NULL) != 0) {
        perror("gettimeofday failed");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    uint64_t elapsed_us = (now.tv_sec * 1e6) + now.tv_usec;
#else
    struct timespec tick;
    if (clock_gettime(CLOCK_MONOTONIC, &tick) != 0) {
        perror("clock_gettime");
        // mlonmcu_exit(1);  // TODO: improve
        return 0;
    }
    uint64_t elapsed_us = tick.tv_sec * 1e6 + tick.tv_nsec / 1e3;
#endif
    return elapsed_us;
}

#endif  // TARGETLIB_LINUX_TIME_H
