#include <stdio.h>
#include "printing.h"
#include "config.h"
#include "rvv_bench_utils.h"

static ux mem[128];
static ux seed = 123456;

extern char const benchmark_names;
extern ux (*benchmarks)(void);
extern ux run_bench(ux (*bench)(void), void *ptr, ux seed);

#define PRINTF_FIX  // TODO: expose

static int
compare_ux(void const *a, void const *b)
{
	return (*(ux*)a > *(ux*)b) - (*(ux*)a < *(ux*)b);
}

void
run(char const *name, ux (*bench)(void)) {
	ux arr[RUNS];

	// print("<tr><td>")(s,name)("</td>");
	mlonmcu_printf("<tr><td>%s</td>", name);
	for (ux i = 0; i < RUNS; ++i) {
		arr[i] = run_bench(bench, mem, seed);
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

#ifdef PRINTF_FIX
	double val = (double)(sum * 1.0f/(UNROLL*LOOP*count));
	mlonmcu_printf("<td>%d.%02d</td>", ((int)(val * 100) / 100), ((int)(val * 100) % 100));
#else
	mlonmcu_printf("<td>%.2f</td>", (double)(sum * 1.0f/(UNROLL*LOOP*count)));
#endif
	mlonmcu_printf("</tr>\n");
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

	ux (**it)(void) = &benchmarks;
	char const *name = &benchmark_names;
	while (*it) {
		run(name, *it);
		++it;
		while (*name++);
	}
  return 0;
}
int mlonmcu_check() {
  return 0;
}
