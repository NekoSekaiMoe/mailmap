if(",${CMAKE_CURRENT_SOURCE_DIR}," STREQUAL ",${CMAKE_CURRENT_BINARY_DIR},")
    # try to clean up (does not work)
    #file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/CMakeCache.txt")
    message(FATAL_ERROR "ERROR: In-source builds are not allowed, please use an extra build dir.")
endif()

cmake_minimum_required(VERSION 3.10)
project(crow_mail LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_compile_options("-Wno-unused-result")
add_compile_options("-Wall")
add_compile_options("-fstack-clash-protection")
add_compile_options("-fstack-protector-all")
add_compile_options("-std=c++17")
add_compile_options("-pipe")

# 添加 Crow 库
add_subdirectory(Crow)

# 添加项目源文件
add_executable(crow_mail main.cpp yaml_parser.cpp)
target_link_libraries(crow_mail PRIVATE Crow::Crow boost_filesystem)

set(CMAKE_COLOR_DIAGNOSTICS ON)

include(CheckCXXCompilerFlag)
set(FLAGS_TO_CHECK
    "-static"
    "-pipe"
    "-fdata-sections"
    "-ffunction-sections"
    "-fstack-clash-protection"
    "-fstack-protector-all"
    )

set(UNSUPPORTED_FLAGS "")

foreach(FLAG ${FLAGS_TO_CHECK})
    string(REPLACE "-" "_" FLAG_VAR "CXXFLAG_CHECK_${FLAG}")
    check_cxx_compiler_flag(${FLAG} ${FLAG_VAR})
    if(NOT ${FLAG_VAR})
        list(APPEND UNSUPPORTED_FLAGS ${FLAG})
    endif()
endforeach()

if(UNSUPPORTED_FLAGS)
    message(FATAL_ERROR "ERROR: The following CXX flags are not supported: ${UNSUPPORTED_FLAGS}")
endif()

install (TARGETS helper DESTINATION /usr/local/bin/)

