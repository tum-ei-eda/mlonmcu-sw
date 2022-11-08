##### the following can run after directly the helloworld example.
# cd build/bin
# # remember to source pulp-freertos/env/pulp.sh first
# # and run the 'make run-gvsoc' first for the helloworld example

# rm -rdf gvsim
# mkdir gvsim
# /mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/egvsoc.sh --config-file=pulp@config_file=chips/pulp/pulp.json --platform=gvsoc --dir=gvsim --binary=$PWD/generic_mlif prepare run

# cd ../..


##### the following can run without makefile from free-rtos ####
cd build/bin
# remember to source pulp-freertos/env/pulp.sh first
# and run the 'make run-gvsoc' first for the helloworld example



PULP_CURRENT_CONFIG=pulp@config_file=chips/pulp/pulp.json \
PULP_CONFIGS_PATH=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/pulp-configs/configs \
PYTHONPATH=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/install/python \
INSTALL_DIR="/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/install" \
make -C "/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/gvsoc" build ARCHI_DIR=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/archi/include


rm -rdf gvsim
mkdir gvsim
cp generic_mlif gvsim
PULP_RISCV_GCC_TOOLCHAIN=/mnt/d/time_5_semester_TUM/hiwi/pulpino  \
/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/egvsoc.sh --config-file=pulp@config_file=chips/pulp/pulp.json --platform=gvsoc --dir=$PWD/gvsim --binary=generic_mlif prepare run

cd ../..