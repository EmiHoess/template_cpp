if(NOT PROJECT_IS_TOP_LEVEL OR __template__project_name_PACKAGING_MAINTAINER_MODE)
  option(__template__project_name_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
else()
  option(__template__project_name_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" ${SUPPORTS_ASAN})
endif()