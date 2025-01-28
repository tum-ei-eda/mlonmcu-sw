IF(NOT SRC_DIR)
    MESSAGE(FATAL_ERROR "The variable SRC_DIR is not set")
ENDIF()

SET(TVM_OUT_DIR ${SRC_DIR}/codegen/host/)
SET(EXTRA_SRC ml_interface_tvm.c)

FILE(GLOB TVM_SRCS ${TVM_OUT_DIR}/src/*_lib*.c ${TVM_OUT_DIR}/src/*_lib*.cc)
FILE(GLOB TVM_OBJS ${TVM_OUT_DIR}/lib/*_lib*.o)

IF(TVM_OBJS)
    COMMON_ADD_LIBRARY(tvm_extension_objs OBJECT IMPORTED)

    SET_PROPERTY(TARGET tvm_extension_objs PROPERTY
        IMPORTED_OBJECTS ${TVM_OBJS}
    )
    IF(NOT TVM_SRCS)
        COMMON_ADD_LIBRARY(tvm_extension ALIAS tvm_extension_objs)
    ENDIF()
ENDIF()
IF(TVM_SRCS)
    # Need this in extra target to avoid circular dependency .
    COMMON_ADD_LIBRARY(tvm_extension STATIC ${TVM_SRCS})
    TARGET_INCLUDE_DIRECTORIES(tvm_extension PUBLIC ${TVM_HEADERS} ${TVM_OUT_DIR}/include ${SRC_DIR})
    TARGET_LINK_LIBRARIES(tvm_extension PUBLIC m)
    TARGET_LINK_LIBRARIES(tvm_extension PUBLIC ${TVM_LIB})
    TARGET_COMPILE_OPTIONS(tvm_extension PRIVATE -Wno-incompatible-pointer-types)
    IF(TVM_OBJS)
        TARGET_LINK_LIBRARIES(tvm_extension PUBLIC tvm_extension_objs)
    ENDIF()
ENDIF()

IF(${GLOBAL_ISEL})
target_compile_options(tvm_extension PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(tvm_extension PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
ENDIF()

SET(EXTRA_SRC ${EXTRA_SRC} ${SRC_DIR}/${TVM_WRAPPER_FILENAME})
TARGET_LINK_LIBRARIES(${TVM_LIB} PUBLIC tvm_extension m)
SET(EXTRA_INC ${TVM_OUT_DIR}/include ${SRC_DIR})

SET(EXTRA_LIBS tvm_extension ${TVM_LIB})

FOREACH(ENTRY ${TVM_EXTRA_LIBS})
    TARGET_LINK_LIBRARIES(tvm_extension PUBLIC ${ENTRY})
ENDFOREACH()
FOREACH(ENTRY ${TVM_EXTRA_INCS})
    TARGET_INCLUDE_DIRECTORIES(tvm_extension PUBLIC ${ENTRY})
ENDFOREACH()
FOREACH(ENTRY ${TVM_EXTRA_DEPS})
    ADD_DEPENDENCIES(tvm_extension ${TVM_EXTRA_DEPS})
ENDFOREACH()
