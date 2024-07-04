SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR ara)

SET(ARA_APPS_DIR
    ""
    CACHE STRING "base name of the toolchain executables"
)

INCLUDE(targets/ara/araTarget)
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY_ARA(${TARGET_NAME} ${ARGN})
ENDMACRO()
MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    ADD_EXECUTABLE_ARA(${TARGET_NAME} ${ARGN})
ENDMACRO()

# The following is transferred from https://github.com/pulp-platform/ara/blob/70a059a7ed5a8c534e782994d25806bed07f0b83/apps/common/runtime.mk#L34
# +The original config files are located at https://github.com/pulp-platform/ara/tree/70a059a7ed5a8c534e782994d25806bed07f0b83/config
# +The orignal config files suggest the following combinations:
# +nr_lanes = 2 vlen = 2048
# +nr_lanes = 4 vlen = 4096
# +nr_lanes = 8 vlen = 8192
# +nr_lanes = 16 vlen = 16384
SET(MLONMCU_ARA_NR_LANES
    "4"
    CACHE STRING "nr_lanes of ara"
)
SET(MLONMCU_ARA_VLEN
    "4096"
    CACHE STRING "vlan of ara"
)
SET(DEFINES -DNR_LANES=${MLONMCU_ARA_NR_LANES} -DVLEN=${MLONMCU_ARA_VLEN})
ADD_DEFINITIONS(${DEFINES})
# end of transferred from https://github.com/pulp-platform/ara/blob/70a059a7ed5a8c534e782994d25806bed07f0b83/apps/common/runtime.mk#L24-L34

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
