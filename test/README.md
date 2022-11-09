Step 1:
modify the path in scripts
Step 2:
run test_script.sh to compile
Step 3:
run test_simu.sh to simulate
the pulp-freertos/support/install will be populated automatically

If you want to reset the pulp-rtos folder
You can use the following command
git clean -xfd
git submodule foreach --recursive git clean -xfd
git reset --hard
git submodule foreach --recursive git reset --hard
git submodule update --init --recursive
