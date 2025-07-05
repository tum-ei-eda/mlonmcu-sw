#ifndef RVV_BENCH_UTILS_MIN_H
#define RVV_BENCH_UTILS_MIN_H

#if __riscv_xlen == 32
#define IF64(...)
#else
#define IF64(...) __VA_ARGS__
#endif

#if __riscv_v_elen >= 64
#define IF_VE64(...) __VA_ARGS__
#else
#define IF_VE64(...)
#endif

#if __riscv_zfh >= 1000000
#define IF_F16(...) __VA_ARGS__
#else
#define IF_F16(...)
#endif

#if __riscv_zvfh >= 1000000 && IF_F16(1)+0
#define IF_VF16(...) __VA_ARGS__
#else
#define IF_VF16(...)
#endif

#if __riscv_flen == 64
#define IF_F64(...) __VA_ARGS__
#else
#define IF_F64(...)
#endif

#if __riscv_v_elen_fp == 64
#define IF_VF64(...) __VA_ARGS__
#else
#define IF_VF64(...)
#endif


#endif  // RVV_BENCH_UTILS_MIN_H
