IF(NOT PULPINO_TC_DIR)
    SET(PULPINO_TC_DIR ${ETISS_DIR}/examples/SW/riscv/cmake)
ENDIF()
SET(CMAKE_TOOLCHAIN_FILE "${PULPINO_TC_DIR}/pulpino_tumeda/toolchain.cmake")
