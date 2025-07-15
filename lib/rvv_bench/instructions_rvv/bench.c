#include <stdio.h>
#include "printing.h"
#include "config.h"
#include "rvv_bench_utils.h"

static ux seed = 123456;

typedef ux (*BenchFunc)(void);
extern size_t bench_count;
extern char bench_names;
extern ux bench_types;
extern BenchFunc bench_mf8, bench_mf4, bench_mf2, bench_m1, bench_m2, bench_m4, bench_m8;
static BenchFunc *benches[] = { &bench_mf8, &bench_mf4, &bench_mf2, &bench_m1, &bench_m2, &bench_m4, &bench_m8 };

extern ux run_bench(ux (*bench)(void), ux type, ux vl, ux seed);

#if defined(__riscv_zve64x)
#define MAX_SEW_RAW 0b011
#elif defined(__riscv_zve32x)
#define MAX_SEW_RAW 0b010
#else
#error "Unable to detect ELEM"
#endif

static int
compare_ux(void const *a, void const *b)
{
	return (*(ux*)a > *(ux*)b) - (*(ux*)a < *(ux*)b);
}


static int
run_all_types(char const *name, ux bIdx, ux vl, int ta, int ma)
{
	ux arr[RUNS];


	mlonmcu_printf("<tr><td>%s</td>", name);
	ux mask = bIdx[&bench_types];

	ux lmuls[] = { 5, 6, 7, 0, 1, 2, 3 };

	for (ux sew = 0; sew < (MAX_SEW_RAW + 1); ++sew)
	for (ux lmul_idx = 0; lmul_idx < 7; ++lmul_idx) {
		ux lmul = lmuls[lmul_idx];
		ux vtype = lmul | (sew<<3) | (!!ta << 6) | (!!ma << 7);

		if (!(mask >> (lmul_idx*4 + sew) & 1)) {
			mlonmcu_printf("<td></td>");
			continue;
		}

		ux lmul_val = 1 << lmul_idx; // fixed-point, denum 8
		ux sew_val = 1 << (sew + 3);
		// > For a given supported fractional LMUL setting,
		// > implementations must support SEW settings between SEWMIN
		// > and LMUL * ELEN, inclusive.
		if (sew_val * 8 > lmul_val * __riscv_v_elen) {
			mlonmcu_printf("<td></td>");
			continue;
		}

		ux emul = lmul_idx;
		if (mask == T_W || mask == T_FW || mask == T_N || mask == T_FN)
			emul += 1;
		if (mask == T_ei16 && sew == 0)
			emul = emul < 7 ? emul+1 : 7;
		if (mask == T_m1)
			emul = 4; // m2
		BenchFunc *bench_ptr = benches[emul] + bIdx;
		if (bench_ptr == 0)  // NULL reached!
			return -1;
		BenchFunc bench = *bench_ptr;

		for (ux i = 0; i < RUNS; ++i) {
			arr[i] = run_bench(bench, vtype, vl, seed);
			if (~arr[i] == 0) goto skip;
			seed = seed*7 + 13;
		}
#if RUNS > 4
		qsort(arr, RUNS, sizeof *arr, compare_ux);
		ux sum = 0, count = 0;
		for (ux i = RUNS * 0.2f; i < RUNS * 0.8f; ++i, ++count)
			sum += arr[i];
#else
		ux sum = 0, count = RUNS;
		for (ux i = 0; i < RUNS; ++i)
			sum += arr[i];
#endif
#ifdef PRINTF_FLOAT_FIX
		double val = (double)(sum * 1.0f/(UNROLL*LOOP*count*8));
		mlonmcu_printf("<td>%d.%02d</td>", ((int)(val * 100) / 100), ((int)(val * 100) % 100));
#else
		mlonmcu_printf("<td>%.2f</td>", (double)(sum * 1.0f/(UNROLL*LOOP*count*8)));
#endif
		continue;
skip:
		mlonmcu_printf("<td></td>");
	}
	mlonmcu_printf("</tr>\n");
	return 0;
}


int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}
int mlonmcu_run() {
	size_t x;
	seed = target_cycles();
	seed ^= (uintptr_t)&x;

	ux vlarr[] = { 0, 1 };
	for (ux i = 0; i < 2; ++i) {
		for (ux j = 4; j--; ) {
      // mlonmcu_printf("j=%u.\n", j);
			mlonmcu_printf("\n");
			if (vlarr[i] != 0)
				mlonmcu_printf("vl=%u", vlarr[i]);
			else
				mlonmcu_printf("vl=VLMAX");
			mlonmcu_printf("%s%s", j & 2 ? " ta" : " tu", j & 1 ? " ma" : " mu");
      mlonmcu_printf("\n\n");
			char const *name = &bench_names;
			ux bIdx = 0;
			while(1) {
				int rc = run_all_types(name, bIdx, vlarr[i], j >> 1, j & 1);
        if (rc < 0) {
            break;
        }
				while (*name++)
						;
				bIdx++;
			}
		}
	}
  return 0;
}
int mlonmcu_check() {
  return 0;
}
