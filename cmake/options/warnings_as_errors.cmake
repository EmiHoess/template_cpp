if(NOT PROJECT_IS_TOP_LEVEL OR myproject_PACKAGING_MAINTAINER_MODE)
  option(myproject_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
else()
  option(myproject_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
endif()


macro(set_warning_as_errors)
    if(myproject_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
        # This is not working consistently, so disabling for now
        # target_link_options(myproject_options INTERFACE -Wl,--fatal-warnings)
    endif()
    endif()
endmacro()