PROJECT(rvv_bench_instructions_rvv C CXX ASM)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bench.S
  COMMAND m4 ${CMAKE_CURRENT_LIST_DIR}/gen.S > ${CMAKE_CURRENT_BINARY_DIR}/bench.S
  DEPENDS ${CMAKE_CURRENT_LIST_DIR}/gen.S
  DEPENDS ${CMAKE_CURRENT_LIST_DIR}/gen.S
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMENT "Generating bench.S from gen.S using m4"
  VERBATIM)
add_custom_target(gen_bench_S DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bench.S)
# COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC bench.c bench.S)
COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC bench.c ${CMAKE_CURRENT_BINARY_DIR}/bench.S)
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC . ../common)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PRIVATE support)

add_dependencies(${PROJECT_NAME} gen_bench_S)

IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()
