find_library(LZ4_LIB_DEBUG NAMES lz4d)
find_library(LZ4_LIB_RELEASE NAMES lz4)

add_library(LZ4::LZ4 INTERFACE IMPORTED)

target_link_libraries(LZ4::LZ4
    INTERFACE
        debug ${LZ4_LIB_DEBUG} optimized ${LZ4_LIB_RELEASE}
)
