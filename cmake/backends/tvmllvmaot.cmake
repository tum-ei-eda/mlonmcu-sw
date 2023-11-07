IF("${MLONMCU_FRAMEWORK}" STREQUAL "")
    SET(MLONMCU_FRAMEWORK "tvm")
ENDIF()

SET(TVM_REQUIRED_COMPONENTS a b c)

SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DTVMCG_DEBUG_ALLOCATIONS")

SET(TVM_LIB tvm_aot_rt)
SET(TVM_WRAPPER_FILENAME aot_wrapper.c)
