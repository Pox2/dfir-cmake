macro(orc_add_compile_options)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_definitions(
    UNICODE
    _UNICODE
    NOMINMAX
    BOOST_NO_SWPRINTF
    _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
    _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
)

if(${TARGET_ARCH} STREQUAL "x64")
    add_compile_definitions(
        _WIN64
    )
endif()

add_compile_options(
    /wd4995
    /EHa      # Enable C++ exception with SEH (required by Robustness.cpp: _set_se_translator)
  # /Gy       # Enable function level linking
  # /JMC      # Debug only Just My Code
    /MP       # Multi processor compilation
    /Oy-      # Omit frame pointer
    /Qpar     # Enable Parallel Code Generation
    /Qspectre-  # No need of mitigation as MS does not enable his as administrator
    /sdl      # Enable additional security checks
    /Yustdafx.h
  # /Zi       # Program database for edit and continue (debug only)
)

list(APPEND COMPILE_OPTIONS_RELEASE
    /guard:cf  # Enable control flow guard
)

if(ORC_USE_STATIC_CRT)
    set(CRT_TYPE "/MT")
else()
    set(CRT_TYPE "/MD")
endif()

list(APPEND COMPILE_OPTIONS_DEBUG "${CRT_TYPE}d")
list(APPEND COMPILE_OPTIONS_RELEASE "${CRT_TYPE}")

foreach(OPTION IN ITEMS ${COMPILE_OPTIONS_DEBUG})
    add_compile_options($<$<CONFIG:DEBUG>:${OPTION}>)
endforeach()

foreach(OPTION IN ITEMS ${COMPILE_OPTIONS_RELEASE})
    add_compile_options($<$<CONFIG:RELEASE>:${OPTION}>)
    add_compile_options($<$<CONFIG:MINSIZEREL>:${OPTION}>)
    add_compile_options($<$<CONFIG:RELWITHDEBINFO>:${OPTION}>)
endforeach()

list(APPEND CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "/DEBUG")

# Always add precompiled header creation flag
set_source_files_properties(stdafx.cpp PROPERTIES COMPILE_FLAGS "/Ycstdafx.h")

endmacro()
