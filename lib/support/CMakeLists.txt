COMMON_ADD_LIBRARY(support STATIC dummy.c exit.c printing.c)
TARGET_INCLUDE_DIRECTORIES(support PUBLIC . ../targets)
TARGET_LINK_LIBRARIES(support PRIVATE target_support)
