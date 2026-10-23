# Dashboard settings shared by build.cmake and submit.cmake, read from the
# CDASH_* environment variables documented in submit.cmake. Both scripts must
# see the same values so that the build and the tests land in one CDash entry.

cmake_minimum_required(VERSION 3.25)

foreach(var SOURCE_DIR BINARY_DIR BUILD_NAME SITE)
    if(NOT DEFINED ENV{CDASH_${var}})
        message(FATAL_ERROR "CDASH_${var} is not set")
    endif()
endforeach()

set(CTEST_SOURCE_DIRECTORY "$ENV{CDASH_SOURCE_DIR}")
set(CTEST_BINARY_DIRECTORY "$ENV{CDASH_BINARY_DIR}")
set(CTEST_BUILD_NAME       "$ENV{CDASH_BUILD_NAME}")
set(CTEST_SITE             "$ENV{CDASH_SITE}")

set(track "$ENV{CDASH_TRACK}")
if(NOT track)
    set(track Nightly)
endif()
