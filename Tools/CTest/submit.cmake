# Runs the test suite and publishes the results to the AMReX dashboard at
# https://my.cdash.org/index.php?project=AMReX
#
#   ctest -S /path/to/amrex/Tools/CTest/submit.cmake [-C <config>]
#
# The build must already be configured and built; multi-config generators
# such as Visual Studio need -C <config>. If the build was done with
# build.cmake, the test results are recorded under the same dashboard TAG so
# that CDash also shows the build time, warnings and errors. Driven by
# environment variables so the same script serves GitHub Actions and GitLab CI:
#
#   CDASH_SOURCE_DIR   top of the AMReX source tree
#   CDASH_BINARY_DIR   the configured build directory
#   CDASH_BUILD_NAME   label for this configuration, e.g. nvidia-h100-cuda
#   CDASH_SITE         where it ran, e.g. hpsf-gitlab
#   CDASH_TRACK        dashboard track; defaults to Nightly
#   CDASH_AUTH_TOKEN   bearer token, if the project requires authentication
#
# The token is passed through the CTest API rather than the --http-header
# command-line option, which needs CMake 3.29; the GPU images ship 3.28.

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

# Reuse the TAG written by build.cmake, if any, so Build.xml is submitted too
set(append "")
if(EXISTS "${CTEST_BINARY_DIRECTORY}/Testing/TAG")
    set(append APPEND)
endif()

ctest_start("${track}" ${append})
ctest_test(RETURN_VALUE test_result)

set(submit_args "")
if(NOT "$ENV{CDASH_AUTH_TOKEN}" STREQUAL "")
    set(submit_args HTTPHEADER "Authorization: Bearer $ENV{CDASH_AUTH_TOKEN}")
endif()
ctest_submit(${submit_args} RETURN_VALUE submit_result)

message(STATUS "ctest_test result: ${test_result}, ctest_submit result: ${submit_result}")

# Note for callers: ctest -S exits non-zero when a submission fails, so invoke
# this with continue-on-error (GitHub Actions) or `|| true` (GitLab CI). A test
# failure is already reported by the job's own ctest run, and an unreachable
# dashboard is not a broken build.
