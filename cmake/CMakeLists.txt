# Copyright (c) 2011, 2012 Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})


option(tests   "Enable tests" ON)
option(arch    "Build for ia32, x64, or Arm" OFF)
option(release "Release build" ON)


if(arch STREQUAL x64)
    set(x64 1)
elseif(arch STREQUAL arm)
    include(Arm)
elseif(arch STREQUAL ia32)
    set(arch ia32)
    set(ia32 1)
endif()
if(arch)
    message(STATUS "Building for architecture ${arch}")
endif()


project(dart)


set(EXECUTABLE_OUTPUT_PATH  ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH     ${CMAKE_BINARY_DIR}/lib)


if(V)
    set(CMAKE_VERBOSE_MAKEFILE ON)
    set(verbose ON)
else()
    message(STATUS)
    message(STATUS "Use option '-DV=1' to enable verbose build")
endif()


if(release)
    set(CMAKE_BUILD_TYPE Release)
else()
    set(CMAKE_BUILD_TYPE Debug)
endif()
if(verbose)
    message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
endif()


include(DartLibraries)


include(DartExecutables)


#
# test
#

if(tests)
    enable_testing()

    t_init(run_vm_tests)
    t_findSources(vm _test.cc)
    t_findSources(bin _test.cc)
    t_addSources(bin/run_vm_tests.cc)
    t_removeSources(ALL process_test )
    t_addDartFiles(vm/snapshot_test.dart)
    t_embedDartFiles(vm/snapshot_test_in.dat ${gen_dir}/snapshot_test.dat " " " ")
    t_includeDirectoriesAbsolute(${gen_dir})
    t_includeDirectories(.)
    t_addDefinitions(TESTING)
    t_linkLibraries(${libdart_withcore})
    t_makeTest()


    message(STATUS)
    get_filename_component(rep_root ${t_top}/.. ABSOLUTE)
    message(STATUS "Run tests from the source folder: '${rep_root}' !")
    message(STATUS)
endif()

