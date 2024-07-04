cd build/bin

source /mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/env/pulp.sh

PULP_CURRENT_CONFIG=pulp@config_file=chips/pulp/pulp.json \
PULP_CONFIGS_PATH=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/pulp-configs/configs \
PYTHONPATH=/tmp/pulp-freertos/support/install/python \
INSTALL_DIR="/tmp/pulp-freertos/support/install" \
make -C "/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/gvsoc" build ARCHI_DIR=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/archi/include

rm -rdf gvsim
mkdir gvsim
cp generic_mlif gvsim
PULP_RISCV_GCC_TOOLCHAIN=/mnt/d/time_5_semester_TUM/hiwi/pulpino  \
/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/egvsoc.sh --config-file=pulp@config_file=chips/pulp/pulp.json --platform=gvsoc --dir=$PWD/gvsim --binary=generic_mlif prepare run

cd ../..