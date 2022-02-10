IF ("${FRAMEWORK}" STREQUAL "")
    SET(FRAMEWORK "tvm")
ENDIF()

SET(TVM_REQUIRED_COMPONENTS a b c)

SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DTVMAOT_DEBUG_ALLOCATIONS")

SET(TVM_LIB tvm_aot_rt)
SET(TVM_WRAPPER_FILENAME aot_wrapper.c)
