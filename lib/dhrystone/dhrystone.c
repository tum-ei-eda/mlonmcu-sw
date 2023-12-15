void dhrystone_init();
void dhrystone_deinit();
void dhrystone_main();

int mlonmcu_init() {
  dhrystone_init();
  return 0;
}

int mlonmcu_deinit() {
  dhrystone_deinit();
  return 0;
}

int mlonmcu_run() {
  dhrystone_main();
  return 0;
}

int mlonmcu_check() {
  return 0;
}
