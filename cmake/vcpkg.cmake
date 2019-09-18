#
# vcpkg_check_boostrap: check if bootstrap is needed
#
#   ARGUMENTS
#       VCPKG_PATH               path      vcpkg path
#       BUILD                    ON/OFF    bootstrap and build vcpkg if needed
#
#   RESULT
#       VCPKG_BOOTSTRAP_FOUND    BOOL      TRUE if vcpkg executable is found
#
function(vcpkg_check_boostrap)
    set(OPTIONS)
    set(SINGLE PATH BUILD)
    set(MULTI)

    cmake_parse_arguments(VCPKG "${OPTIONS}" "${SINGLE}" "${MULTI}" ${ARGN})

    set(VCPKG_EXE "${VCPKG_PATH}/vcpkg.exe")
    if(NOT EXISTS "${VCPKG_EXE}")
        if(NOT VCPKG_BUILD)
            message(FATAL_ERROR "Cannot find '${VCPKG_EXE}'")
        endif()

        execute_process(
            COMMAND "bootstrap-vcpkg.bat"
            WORKING_DIRECTORY ${VCPKG_PATH}
            RESULT_VARIABLE RESULT
        )

        if(NOT "${RESULT}" STREQUAL "0")
            message(FATAL_ERROR
                "Failed to bootstrap using '${VCPKG_PATH}': ${RESULT}"
            )
        endif()
    endif()

    message(STATUS "Using vcpkg: ${VCPKG_EXE}")

    set(VCPKG_BOOTSTRAP_FOUND TRUE PARENT_SCOPE)
endfunction()

#
# vcpkg_install_packages: display and optionally install required dependencies
#
#   ARGUMENTS
#       VCPKG_PATH            path        vcpkg path
#       PACKAGES              list        list of packages to be installed
#       ARCH                  x86/x64     build architecture
#       USE_STATIC_CRT        ON/OFF      use static runtime
#       BUILD                 ON/OFF      build packages if needed
#
#   RESULT
#       VCPKG_PACKAGES_FOUND  BOOL        TRUE if pacakges are found
#
function(vcpkg_install_packages)
    set(OPTIONS)
    set(SINGLE PATH ARCH USE_STATIC_CRT BUILD)
    set(MULTI PACKAGES)

    cmake_parse_arguments(VCPKG "${OPTIONS}" "${SINGLE}" "${MULTI}" ${ARGN})

    if(VCPKG_USE_STATIC_CRT)
        set(CRT_LINK "-static")
    endif()

    # Install the package matching the triplet if none provided
    foreach(PKG IN ITEMS ${VCPKG_PACKAGES})
        string(REGEX MATCH ".*:.*" match ${PKG})
        if(match)
            list(APPEND PACKAGES "${PKG}")
        else()
            list(APPEND PACKAGES "${PKG}:${VCPKG_ARCH}-windows${CRT_LINK}")
        endif()
    endforeach()

    list(JOIN PACKAGES " " PACKAGES_STR)
    message(STATUS "Install dependencies with: "
        "\"${VCPKG_PATH}\\vcpkg.exe\" --vcpkg-root \"${VCPKG_PATH}\" "
        "install ${PACKAGES_STR}\n"
    )

    if(VCPKG_BUILD)
        execute_process(
            COMMAND "vcpkg" --vcpkg-root ${VCPKG_PATH} install ${PACKAGES}
            WORKING_DIRECTORY ${VCPKG_PATH}
            RESULT_VARIABLE RESULT
        )

        if(NOT "${RESULT}" STREQUAL "0")
            message(FATAL_ERROR "Failed to install packages: ${RESULT}")
        endif()
    endif()

    set(VCPKG_PACKAGES_FOUND TRUE PARENT_SCOPE)
endfunction()

#
# vcpkg_setup_environment: setup CMAKE_TOOLCHAIN_FILE and VCPKG_TARGET_TRIPLET
#
#   ARGUMENTS
#       VCPKG_PATH            path        vcpkg path
#       ARCH                  x86/x64     build architecture
#       USE_STATIC_CRT        ON/OFF      use static runtime
#
#   RESULT
#       CMAKE_TOOLCHAIN_FILE  path        vcpkg toolchain
#       VCPKG_TARGET_TRIPLET  triplet     triplet to use
#
function(vcpkg_setup_environment)
    set(OPTIONS)
    set(SINGLE PATH ARCH USE_STATIC_CRT)
    set(MULTI PACKAGES)

    cmake_parse_arguments(VCPKG "${OPTIONS}" "${SINGLE}" "${MULTI}" ${ARGN})

    # Deduce CMAKE_TOOLCHAIN_FILE from VCPKG_PATH
    if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
        set(CMAKE_TOOLCHAIN_FILE
            ${VCPKG_PATH}\\scripts\\buildsystems\\vcpkg.cmake PARENT_SCOPE)
    endif()

    # Define the vcpkg triplet from the generator if not defined
    if(NOT VCPKG_TARGET_TRIPLET)
        if(VCPKG_USE_STATIC_CRT)
            set(CRT_LINK "-static")
        endif()
        set(VCPKG_TARGET_TRIPLET
            "${VCPKG_ARCH}-windows${CRT_LINK}" PARENT_SCOPE
        )
    endif()
endfunction()

#
# vcpkg_install: display and optionally install required dependencies
#
#   ARGUMENTS
#       VCPKG_PATH            path        vcpkg path
#       PACKAGES              list        list of packages to be installed
#       ARCH                  x86/x64     build architecture
#       USE_STATIC_CRT        ON/OFF      use static runtime
#       BUILD                 ON/OFF      build packages if needed
#
#   RESULT
#       VCPKG_FOUND           BOOL        TRUE if vcpkg is found and setup
#       CMAKE_TOOLCHAIN_FILE  path        vcpkg toolchain
#       VCPKG_TARGET_TRIPLET  triplet     triplet to use
#
function(vcpkg_install)
    set(OPTIONS)
    set(SINGLE PATH ARCH USE_STATIC_CRT BUILD)
    set(MULTI PACKAGES)

    cmake_parse_arguments(VCPKG "${OPTIONS}" "${SINGLE}" "${MULTI}" ${ARGN})

    vcpkg_check_boostrap(
        PATH ${VCPKG_PATH}
        BUILD ${VCPKG_BUILD}
    )

    vcpkg_install_packages(
       PATH ${VCPKG_PATH}
       PACKAGES ${VCPKG_PACKAGES}
       ARCH ${VCPKG_ARCH}
       USE_STATIC_CRT ${VCPKG_USE_STATIC_CRT}
       BUILD ${VCPKG_BUILD}
    )

    vcpkg_setup_environment(
        PATH ${VCPKG_PATH}
        ARCH ${VCPKG_ARCH}
        USE_STATIC_CRT ${VCPKG_USE_STATIC_CRT}
    )

    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE} PARENT_SCOPE)
    set(VCPKG_TARGET_TRIPLET ${VCPKG_TARGET_TRIPLET} PARENT_SCOPE)
    set(VCPKG_FOUND TRUE PARENT_SCOPE)
endfunction()
