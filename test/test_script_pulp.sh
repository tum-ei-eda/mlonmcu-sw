# create build directory
if [ -d build ]; then
    rm -rdf build
fi
mkdir build
cd build

cp ../../CMakeLists.txt .
cp -rd ../../cmake .
cp -rd ../../generic .
cp -rd ../../lib .

cmake  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
 . \
 -DRISCV_ELF_GCC_PREFIX=/mnt/d/time_5_semester_TUM/hiwi/pulpino \
 -DCMAKE_BUILD_TYPE=Debug \
 -DRISCV_ELF_GCC_BASENAME=riscv32-unknown-elf \
 -DRISCV_ARCH=rv32imac \
 -DRISCV_ABI=ilp32 \
 -DRISCV_ATTR=+i,+m,+a,+c \
 -DTARGET_SYSTEM=gvsoc_pulp \
 -DMLONMCU_BACKEND=tvmaot \
 -DMLONMCU_FRAMEWORK=tvm \
 -DTVM_CRT_CONFIG_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu/mlonmcu/../resources/frameworks/tvm/crt_config \
 -DTVM_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu_env/deps/src/tvm \
 -DTOOLCHAIN=gcc \
 -DLLVM_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu_env/deps/install/llvm \
 -DMODEL_SUPPORT_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu_env/models/resnet/support \
 -DSRC_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu_env/temp/sessions/49/runs/0 \
 -DDATA_SRC=


# -DRISCV_ATTR=+c,+i,+f,+m,+d,+a \

#  -DETISS_DIR=/mnt/d/time_5_semester_TUM/hiwi/mlonmcu_env/deps/install/etiss \

#  -DPULPINO_ROM_START=0 \
#  -DPULPINO_ROM_SIZE=8388608 \
#  -DPULPINO_RAM_START=8388608 \
#  -DPULPINO_RAM_SIZE=67108864 \
make
cd ..
