IF(RISCV_AUTO_VECTORIZE)
  IF(${TOOLCHAIN} STREQUAL "llvm")
    INCLUDE(auto_vectorize_llvm)
  ELSEIF(${TOOLCHAIN} STREQUAL "gcc")
    INCLUDE(auto_vectorize_gcc)
  ELSE()
    MESSAGE(FATAL_ERROR "Unsupported TOOLCHAIN '${TOOLCHAIN}' for auto_vectorize feature.")
  ENDIF()
ENDIF()