find_library(BOOST_FILESYSTEM_DEBUG_LIB NAMES boost_filesystem-vc140-mt-gd)
find_library(BOOST_FILESYSTEM_RELEASE_LIB NAMES boost_filesystem-vc140-mt)

add_library(boost::filesystem INTERFACE IMPORTED)

target_link_libraries(boost::filesystem
    INTERFACE
        debug ${BOOST_FILESYSTEM_DEBUG_LIB}
        optimized ${BOOST_FILESYSTEM_RELEASE_LIB}
)
