cd build/bin

# change the path in the script

# install package 
# sudo apt-get install build-essential python-dev libsdl2-dev

source /mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/env/pulp.sh

PULP_CURRENT_CONFIG=pulpissimo@config_file=chips/pulpissimo/pulpissimo.json \
PULP_CONFIGS_PATH=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/pulp-configs/configs \
PYTHONPATH=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/install/python \
INSTALL_DIR=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/install \
ARCHI_DIR=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/archi/include \
SUPPORT_ROOT=/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support \
make -C "/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support" -f "/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/support.mk" gvsoc

rm -rdf gvsim
mkdir gvsim
cp generic_mlif gvsim

PULP_RISCV_GCC_TOOLCHAIN=/mnt/d/time_5_semester_TUM/hiwi/pulpino  \
/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/egvsoc.sh --config-file=pulpissimo@config_file=chips/pulpissimo/pulpissimo.json --platform=gvsoc --dir=$PWD/gvsim --binary=generic_mlif prepare run 

cd ../..