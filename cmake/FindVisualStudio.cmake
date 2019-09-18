if(DEFINED ENV{VCINSTALLDIR})
    set(VS_INSTALL_DIR $ENV{VCINSTALLDIR}/..)
else()
    set(VS_INSTALL_DIR ${CMAKE_GENERATOR_INSTANCE})
endif()

#from architecture.cmake
get_target_architecture(RESULT_VARIABLE "TARGET_ARCH")

## CppUnitTest
find_path(CPPUNITTEST_INCLUDE_DIR "CppUnitTest.h"
    PATHS
        "${VS_INSTALL_DIR}/VC"
        "${VS_INSTALL_DIR}/VC/Auxiliary/VS"
    PATH_SUFFIXES
        "UnitTest/include"
    DOC
        "VS UnitTest include directory"
)

set(LIBRARY_NAME "Microsoft.VisualStudio.TestTools.CppUnitTestFramework.lib")

find_path(CPPUNITTEST_LIB_DIR "${LIBRARY_NAME}"
    PATHS
        "${VS_INSTALL_DIR}"
        "${VS_INSTALL_DIR}/VC/Auxiliary/VS"
    PATH_SUFFIXES
        "UnitTest/lib/${TARGET_ARCH}"
    DOC
        "VS UnitTest lib directory"
)

set(CPPUNITTEST_LIBRARY "${CPPUNITTEST_LIB_DIR}/${LIBRARY_NAME}")

## atls / atlmfc
# Resolve VC tools installation directory
# .../Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.20.27508/bin/Hostx64/x64/link.exe
# .../Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.20.27508
get_filename_component(VC_TOOLS "${CMAKE_LINKER}/../../../.." ABSOLUTE)

find_path(ATLS_LIB_DIR "atls.lib"
    PATHS
        "${VC_TOOLS}"

    PATH_SUFFIXES
        "atlmfc/lib/${TARGET_ARCH}"
    DOC
        "ATL MFC library directory"
)

## targets
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VisualStudio
    DEFAULT_MSG
    VS_INSTALL_DIR
    ATLS_LIB_DIR
    CPPUNITTEST_INCLUDE_DIR
)

if(NOT TARGET VisualStudio::atls)
    add_library(VisualStudio::atls INTERFACE IMPORTED)

    set_target_properties(VisualStudio::atls
        PROPERTIES
            INTERFACE_LINK_DIRECTORIES "${ATLS_LIB_DIR}"
    )

    target_link_libraries(VisualStudio::atls INTERFACE "atls.lib")
endif()

if(NOT TARGET VisualStudio::CppUnitTest)
    # Instead of including absolute path do the library, the library directory
    # must be include instead because of the following:
    #
    # CppUnitTestCommon.h
    #
    #    if ((defined _M_AMD64) || (defined _AMD64_))
    #        pragma comment(lib, "x64\\Microsoft...CppUnitTestFramework.lib")
    #    elif ((defined _M_ARM) || (defined _ARM_))
    #    ...
    #
    get_filename_component(CPPUNITTEST_LIB_DIR
        "${CPPUNITTEST_LIB_DIR}/.." ABSOLUTE
    )

    add_library(VisualStudio::CppUnitTest INTERFACE IMPORTED)

    target_include_directories(VisualStudio::CppUnitTest
       INTERFACE
           "${CPPUNITTEST_INCLUDE_DIR}"
    )

    # Cannot use 'target_link_directories' before CMake 3.13
    set_target_properties(VisualStudio::CppUnitTest
        PROPERTIES
            INTERFACE_LINK_DIRECTORIES "${CPPUNITTEST_LIB_DIR}"
    )

    target_link_libraries(VisualStudio::CppUnitTest
        INTERFACE
            "${CPPUNITTEST_LIBRARY}"
    )
endif()
