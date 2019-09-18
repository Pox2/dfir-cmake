if(ORC_USE_STATIC_CRT)
    find_library(ZSTD_LIB_DEBUG NAMES zstd_staticd)
    find_library(ZSTD_LIB_RELEASE NAMES zstd_static)
else()
    find_library(ZSTD_LIB_DEBUG NAMES zstdd)
    find_library(ZSTD_LIB_RELEASE NAMES zstd)
endif()

add_library(ZSTD::ZSTD INTERFACE IMPORTED)

target_link_libraries(ZSTD::ZSTD
    INTERFACE
        debug ${ZSTD_LIB_DEBUG} optimized ${ZSTD_LIB_RELEASE}
)
