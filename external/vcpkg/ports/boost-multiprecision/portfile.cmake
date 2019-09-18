# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multiprecision
    REF boost-1.70.0
    SHA512 a583b0df0855146ad0ee841cfc9ad646be89b38cf0d895d9ba69f4e5b2013887343863678bfbaed055b55c54d2ebe4026dc38f2dc021b8c7f9f18bf540d9189c
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
