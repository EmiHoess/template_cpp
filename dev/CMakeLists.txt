add_executable(dev main.cpp)

target_link_libraries(
  dev
  PRIVATE myproject::myproject_options
          myproject::myproject_warnings
          )

#target_link_system_libraries(
#  dev
#  PRIVATE
#          )

