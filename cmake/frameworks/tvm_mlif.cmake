SET(TVM_OUT_DIR ${SRC_DIR}/codegen/host/src)
SET(EXTRA_SRC ml_interface_tvm.c)

FILE(
    GLOB
    TVM_SRCS
    ${TVM_OUT_DIR}/*_lib*.c
    ${TVM_OUT_DIR}/*_lib*.cc
)

# Need this in extra target to avoid circular dependency .
COMMON_ADD_LIBRARY(tvm_extension STATIC ${TVM_SRCS})

SET(EXTRA_SRC ${EXTRA_SRC} ${SRC_DIR}/${TVM_WRAPPER_FILENAME})
TARGET_LINK_LIBRARIES(${TVM_LIB} PUBLIC tvm_extension)
SET(EXTRA_INC ${TVM_OUT_DIR})

TARGET_INCLUDE_DIRECTORIES(tvm_extension PUBLIC ${TVM_HEADERS} ${TVM_OUT_DIR} ${SRC_DIR})
TARGET_LINK_LIBRARIES(tvm_extension PUBLIC m)
TARGET_LINK_LIBRARIES(tvm_extension PUBLIC ${TVM_LIB})
SET(EXTRA_LIBS tvm_extension ${TVM_LIB})