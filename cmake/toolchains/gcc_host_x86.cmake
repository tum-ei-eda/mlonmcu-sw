SET(TC_VARS
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
)

SET(TC_C_FLAGS "")
SET(TC_CXX_FLAGS "")
SET(TC_ASM_FLAGS "")
SET(TC_LD_FLAGS "")
# Nothing to do...

foreach(X IN ITEMS ${TC_C_FLAGS} ${EXTRA_CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_CXX_FLAGS} ${EXTRA_CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_ASM_FLAGS} ${EXTRA_CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_LD_FLAGS} ${EXTRA_CMAKE_LD_FLAGS} ${FEATURE_EXTRA_LD_FLAGS})
    add_link_options("SHELL:${X}")
endforeach()
