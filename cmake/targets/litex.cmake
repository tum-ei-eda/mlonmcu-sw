SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR litex)

set(LITEX_ROOT "/path/to/litex" CACHE STRING "Root directory of litex installation")
set(LITEX_WORKDIR "/path/to/workdir" CACHE STRING "Litex workdir")

# SET(ETISS_CRT_DIR ${CMAKE_CURRENT_LIST_DIR}/etiss)
SET(LITEX_CRT0 ${LITEX_ROOT}/litex/litex/soc/cores/cpu/${LITEX_CPU}/crt0.S)
SET(LINKER_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/litex/linker.ld)

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
	  SET(SRC_FILES "${ARGN}")
    # ADD_SUBDIRECTORY(litex ${CMAKE_CURRENT_BINARY_DIR}/litex)
    # MESSAGE(FATAL_ERROR "${TARGET_NAME} ${SRC_FILES} ${LITEX_CRT0}")

	  ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES} ${LITEX_CRT0})
	  # ADD_DEPENDENCIES(${TARGET_NAME} etiss_crt0)
    # SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ETISS_LDFLAGS}")
    # TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE etiss_crt0)
    target_link_options(${TARGET_NAME} PRIVATE
        -T ${LINKER_SCRIPT} -N
        # -Wl,--whole-archive
        -Wl,--undefined=uart_write
        -Wl,--gc-sections
        -Wl,--no-dynamic-linker -Wl,--build-id=none
        -Wl,-Map,demo.elf.map
        -nostartfiles
        # -nostdlib
        -L${LITEX_WORKDIR}/software/include/
        -L${LITEX_WORKDIR}/software/libc
        -L${LITEX_WORKDIR}/software/libcompiler_rt
        -L${LITEX_WORKDIR}/software/libbase
        -L${LITEX_WORKDIR}/software/libfatfs
        -L${LITEX_WORKDIR}/software/liblitespi
        -L${LITEX_WORKDIR}/software/liblitedram
        -L${LITEX_WORKDIR}/software/libliteeth
        -L${LITEX_WORKDIR}/software/liblitesdcard
        -L${LITEX_WORKDIR}/software/liblitesata
        -L${LITEX_WORKDIR}/software/bios
    )

    target_link_libraries(${TARGET_NAME} PRIVATE
        # -lc
        -lcompiler_rt
        -lbase
        # /work/git/mlonmcu-litex-sw/outputs/build/sim/software/bios/sim_debug.o
        -lfatfs
        -llitespi
        -llitedram
        -lliteeth
        -llitesdcard
        -llitesata
        -lc
        -lgcc
        -lm
    )
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME} ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.bin
        COMMENT "Creating binary")
ENDMACRO()
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    target_link_libraries(${TARGET_NAME} PRIVATE
        m
    )
    # IF("${ARGV1}" STREQUAL "ALIAS")
    #     # do nothing
    # ELSEIF("${ARGV1}" STREQUAL "INTERFACE")
    #     IF(${TOOLCHAIN} STREQUAL "llvm")
    #         TARGET_LINK_LIBRARIES(${TARGET_NAME} INTERFACE c semihost gcc)
    #     ENDIF()
    #     TARGET_LINK_LIBRARIES(${TARGET_NAME} INTERFACE etiss_crt0)
    # ELSEIF("${ARGV1}" STREQUAL "OBJECT" AND "${ARGV2}" STREQUAL "IMPORTED")
    #     IF(${TOOLCHAIN} STREQUAL "llvm")
    #         TARGET_LINK_LIBRARIES(${TARGET_NAME} INTERFACE c semihost gcc)
    #     ENDIF()
    #     TARGET_LINK_LIBRARIES(${TARGET_NAME} INTERFACE etiss_crt0)
    # ELSE()
    #     IF(${TOOLCHAIN} STREQUAL "llvm")
    #         TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE c semihost gcc)
    #     ENDIF()
    #     TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE etiss_crt0)
    # ENDIF()
ENDMACRO()

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
# SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
