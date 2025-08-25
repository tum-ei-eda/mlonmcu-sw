# The Generic system name is used for bare-metal targets (without OS) in CMake
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR generic_riscv)

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

SET(HTIF OFF CACHE BOOL "Enable libgloss-htif")
SET(HTIF_NANO OFF CACHE BOOL "Enable libgloss-htif nano")
SET(HTIF_WRAP OFF CACHE BOOL "Enable libgloss-htif wrap")
SET(HTIF_ARGV OFF CACHE BOOL "Enable libgloss-htif argv")

# Warning: HTIF needs matching gnu compiler!
# TODO: check -fno-common -fno-builtin-printf

SET(HTIF_LDFLAGS "")

IF(HTIF)
    IF(HTIF_NANO)
        SET(HTIF_LDFLAGS "${HTIF_LDFLAGS} -specs=htif_nano.specs")
    ELSE()
        SET(HTIF_LDFLAGS "${HTIF_LDFLAGS} -specs=htif.specs")
    ENDIF()
    IF(HTIF_WRAP)
        SET(HTIF_LDFLAGS "${HTIF_LDFLAGS} -specs=htif_wrap.specs")
    ENDIF()
    IF(HTIF_ARGV)
        SET(HTIF_LDFLAGS "${HTIF_LDFLAGS} -specs=htif_argv.specs")
    ENDIF()
ENDIF()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
	  SET(SRC_FILES "${ARGN}")

	  ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES})

    # TODO: target_link_options?
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${HTIF_LDFLAGS}")
ENDMACRO()
