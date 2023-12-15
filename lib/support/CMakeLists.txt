SET(STRIP_STRINGS
    OFF
    CACHE BOOL "Reduce ROM footprint removing all printf calls (will break metrics)."
)

COMMON_ADD_LIBRARY(support STATIC dummy.c exit.c printing.c)
TARGET_INCLUDE_DIRECTORIES(support PUBLIC . ../targets)
TARGET_LINK_LIBRARIES(support PRIVATE target_support)

IF(STRIP_STRINGS)
    TARGET_COMPILE_DEFINITIONS(support PUBLIC -DSTRIP_STRINGS)
ENDIF()
