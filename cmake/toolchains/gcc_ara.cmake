SET(CMAKE_SYSTEM_NAME Generic)

SET(CMAKE_SYSTEM_PROCESSOR ara)

if(NOT (EXISTS "${TC_PREFIX}gcc${EXE_EXT}"))
   MESSAGE(FATAL_ERROR, "${TC_PREFIX}gcc${EXE_EXT} NOT FOUND")
endif()

SET(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
SET(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
SET(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
SET(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
SET(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# the following is transferred from https://github.com/pulp-platform/ara/blob/70a059a7ed5a8c534e782994d25806bed07f0b83/apps/common/runtime.mk#L95-L99
# -march=$(RISCV_ARCH) -mabi=$(RISCV_ABI) $(DEFINES) -T/../link.ld is added with 'add_definition' in corresponding cmake in target folder"
SET(RISCV_WARNINGS "${RISCV_WARNINGS} -Wunused-variable -Wall -Wextra -Wno-unused-command-line-argument") # -Werror

SET(RISCV_FLAGS_GCC "-mcmodel=medany -static -std=gnu99 -ffast-math -fno-common  ${RISCV_WARNINGS}") #-fno-builtin-printf

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${RISCV_FLAGS_GCC}")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RISCV_FLAGS_GCC}")
SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${RISCV_FLAGS_GCC}")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static -nostartfiles -lm -lgcc ${RISCV_FLAGS_GCC} ")
# end of transferred from https://github.com/pulp-platform/ara/blob/70a059a7ed5a8c534e782994d25806bed07f0b83/apps/common/runtime.mk#L95-L99
