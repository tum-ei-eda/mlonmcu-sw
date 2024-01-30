int app_main();

int mlonmcu_init() {
  return 0;
}

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
  int result = app_main();
  return result;
}
int mlonmcu_check() {
  return 0;
}
