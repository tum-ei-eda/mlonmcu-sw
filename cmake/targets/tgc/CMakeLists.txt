
IF(NOT DEFINED _MK_LIBWRAP)

SET(_MK_LIBWRAP TRUE)

SET(LIBWRAP_DIR ${CMAKE_CURRENT_LIST_DIR}/libwrap)

SET(LIBWRAP_SRCS
    ${LIBWRAP_DIR}/stdlib/malloc.c
    ${LIBWRAP_DIR}/sys/open.c
    ${LIBWRAP_DIR}/sys/lseek.c
    ${LIBWRAP_DIR}/sys/read.c
    ${LIBWRAP_DIR}/sys/write.c
    ${LIBWRAP_DIR}/sys/fstat.c
    ${LIBWRAP_DIR}/sys/stat.c
    ${LIBWRAP_DIR}/sys/close.c
    ${LIBWRAP_DIR}/sys/link.c
    ${LIBWRAP_DIR}/sys/unlink.c
    ${LIBWRAP_DIR}/sys/execve.c
    ${LIBWRAP_DIR}/sys/fork.c
    ${LIBWRAP_DIR}/sys/getpid.c
    ${LIBWRAP_DIR}/sys/kill.c
    ${LIBWRAP_DIR}/sys/wait.c
    ${LIBWRAP_DIR}/sys/isatty.c
    ${LIBWRAP_DIR}/sys/times.c
    ${LIBWRAP_DIR}/sys/sbrk.c
    ${LIBWRAP_DIR}/sys/_exit.c
    ${LIBWRAP_DIR}/misc/write_hex.c
    ${LIBWRAP_DIR}/sys/printf.c
)

SET(LIBWRAP_SYMS malloc free open lseek read write fstat stat close link unlink execve fork getpid jukk wait isatty times sbrk _exit printf puts)
# Includes
INCLUDE_DIRECTORIES(
    ${LIBWRAP_DIR}/../include
    ${LIBWRAP_DIR}/../drivers
    ${LIBWRAP_DIR}/../env
    ${LIBWRAP_DIR}/../env/iss
)

ADD_LIBRARY(LIBWRAP_TGC STATIC ${LIBWRAP_SRCS})
TARGET_COMPILE_OPTIONS(LIBWRAP_TGC PRIVATE -march=${RISCV_ARCH}_zicsr_zifencei -mabi=${RISCV_ABI})

TARGET_INCLUDE_DIRECTORIES(LIBWRAP_TGC PRIVATE ${INCLUDES})

FOREACH(SYM ${LIBWRAP_SYMS})
    LIST(APPEND WRAP_LDFLAGS "-Wl,--wrap=${SYM}")
ENDFOREACH()

SET(LIBWRAP_TGC_LDFLAGS ${WRAP_LDFLAGS} "-L${CMAKE_CURRENT_BINARY_DIR}" "-Wl,--start-group" "-lLIBWRAP_TGC" "-lc" "-Wl,--end-group")

ENDIF(NOT DEFINED _MK_LIBWRAP)
