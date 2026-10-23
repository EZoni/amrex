# Builds a configured tree and records the build (time, warnings, errors) for
# a later submission by submit.cmake, which records the test results under the
# same dashboard TAG:
#
#   ctest -S /path/to/amrex/Tools/CTest/build.cmake [-C <config>] -V
#
# Uses the same CDASH_* environment variables as submit.cmake. Set
# CMAKE_BUILD_PARALLEL_LEVEL to build in parallel. Nothing is submitted here,
# so this is safe to run on every pipeline. Exits non-zero if the build fails.

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

set(CTEST_BUILD_COMMAND "cmake --build \"${CTEST_BINARY_DIRECTORY}\"")
if(CTEST_CONFIGURATION_TYPE)
    string(APPEND CTEST_BUILD_COMMAND " --config ${CTEST_CONFIGURATION_TYPE}")
endif()

ctest_start("${track}")
ctest_build(NUMBER_ERRORS build_errors RETURN_VALUE build_result)

message(STATUS "ctest_build result: ${build_result}, errors: ${build_errors}")

if(NOT build_result EQUAL 0 OR build_errors GREATER 0)
    message(FATAL_ERROR
        "Build failed: ctest_build result ${build_result}, errors ${build_errors}")
endif()
