include(cmake/SystemLink.cmake)
#include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


set (L_PROJECT_NAME myproject)
set (L_PROJECT_VERSION "0.0.1")
set (L_DESCRIPTION "")
set (L_HOMEPAGE_URL "url")
set (L_LANGUAGES CXX C)



macro(myproject_setup_options)
  include(cmake/options/hardening.cmake)
  #option(myproject_ENABLE_HARDENING "Enable hardening" ON)
  #option(myproject_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  
  #cmake_dependent_option(
  #  myproject_ENABLE_GLOBAL_HARDENING
  #  "Attempt to push hardening options to built dependencies"
  #  ON
  #  myproject_ENABLE_HARDENING
  #  OFF)

  #myproject_supports_sanitizers()
  include(cmake/options/sanitizers_support.cmake)

  include(cmake/options/interprocedural_optimization.cmake)
  include(cmake/options/warnings_as_errors.cmake)
  include(cmake/options/user_linker.cmake)

  include(cmake/options/sanitizer_address.cmake)
  include(cmake/options/sanitizer_leak.cmake)
  include(cmake/options/sanitizer_undefined.cmake)
  include(cmake/options/sanitizer_thread.cmake)
  include(cmake/options/sanitizer_memory.cmake)

  include(cmake/options/unity_build.cmake)
  include(cmake/options/clang_tidy.cmake)
  include(cmake/options/cppcheck.cmake)

  if(NOT PROJECT_IS_TOP_LEVEL OR myproject_PACKAGING_MAINTAINER_MODE)
    #option(myproject_ENABLE_IPO "Enable IPO/LTO" OFF)
    #option(myproject_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    #option(myproject_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    #option(myproject_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    #option(myproject_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    #option(myproject_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    #option(myproject_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(myproject_ENABLE_PCH "Enable precompiled headers" OFF)
    option(myproject_ENABLE_CACHE "Enable ccache" OFF)
  else()
    #option(myproject_ENABLE_IPO "Enable IPO/LTO" ON)
    #option(myproject_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    #option(myproject_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    #option(myproject_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    #option(myproject_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    #option(myproject_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    #option(myproject_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    #option(myproject_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    #option(myproject_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    #option(myproject_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(myproject_ENABLE_PCH "Enable precompiled headers" OFF)
    option(myproject_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      myproject_ENABLE_IPO
      myproject_WARNINGS_AS_ERRORS
      myproject_ENABLE_USER_LINKER
      myproject_ENABLE_SANITIZER_ADDRESS
      myproject_ENABLE_SANITIZER_LEAK
      myproject_ENABLE_SANITIZER_UNDEFINED
      myproject_ENABLE_SANITIZER_THREAD
      myproject_ENABLE_SANITIZER_MEMORY
      myproject_ENABLE_UNITY_BUILD
      myproject_ENABLE_CLANG_TIDY
      myproject_ENABLE_CPPCHECK
      #myproject_ENABLE_COVERAGE
      myproject_ENABLE_PCH
      myproject_ENABLE_CACHE)
  endif()

  #myproject_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  #if(LIBFUZZER_SUPPORTED AND (myproject_ENABLE_SANITIZER_ADDRESS OR myproject_ENABLE_SANITIZER_THREAD OR myproject_ENABLE_SANITIZER_UNDEFINED))
  #  set(DEFAULT_FUZZER ON)
  #else()
  #  set(DEFAULT_FUZZER OFF)
  #endif()
  #option(myproject_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(myproject_global_options)
  #if(myproject_ENABLE_IPO)
  myproject_enable_ipo()
 
  #myproject_enable_ipo()
  #endif()

  #myproject_supports_sanitizers()
  include(cmake/options/sanitizers_support.cmake)
  if(myproject_ENABLE_HARDENING AND myproject_ENABLE_GLOBAL_HARDENING)
    if(NOT SUPPORTS_UBSAN 
       OR myproject_ENABLE_SANITIZER_UNDEFINED
       OR myproject_ENABLE_SANITIZER_ADDRESS
       OR myproject_ENABLE_SANITIZER_THREAD
       OR myproject_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${myproject_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${myproject_ENABLE_SANITIZER_UNDEFINED}")
    myproject_enable_hardening(myproject_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(myproject_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(myproject_warnings INTERFACE)
  add_library(myproject_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  myproject_set_project_warnings(
    myproject_warnings
    ${myproject_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  #if(myproject_ENABLE_USER_LINKER)
  #  include(cmake/Linker.cmake)
  myproject_user_linker_configure(myproject_options)
  #endif()

  include(cmake/Sanitizers.cmake)
  myproject_enable_sanitizers(
    myproject_options
    ${myproject_ENABLE_SANITIZER_ADDRESS}
    ${myproject_ENABLE_SANITIZER_LEAK}
    ${myproject_ENABLE_SANITIZER_UNDEFINED}
    ${myproject_ENABLE_SANITIZER_THREAD}
    ${myproject_ENABLE_SANITIZER_MEMORY})

  set_target_properties(myproject_options PROPERTIES UNITY_BUILD ${myproject_ENABLE_UNITY_BUILD})

  if(myproject_ENABLE_PCH)
    target_precompile_headers(
      myproject_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(myproject_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    myproject_enable_cache()
  endif()

  #include(cmake/StaticAnalyzers.cmake)
  if(myproject_ENABLE_CLANG_TIDY)
    myproject_enable_clang_tidy(myproject_options ${myproject_WARNINGS_AS_ERRORS})
  endif()

  if(myproject_ENABLE_CPPCHECK)
    myproject_enable_cppcheck(${myproject_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  #if(myproject_ENABLE_COVERAGE)
  #  include(cmake/Tests.cmake)
  #  myproject_enable_coverage(myproject_options)
  #endif()

  myproject_set_fatal_warnings_linker_options()

  if(myproject_ENABLE_HARDENING AND NOT myproject_ENABLE_GLOBAL_HARDENING)
    if(NOT SUPPORTS_UBSAN 
       OR myproject_ENABLE_SANITIZER_UNDEFINED
       OR myproject_ENABLE_SANITIZER_ADDRESS
       OR myproject_ENABLE_SANITIZER_THREAD
       OR myproject_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    myproject_enable_hardening(myproject_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
