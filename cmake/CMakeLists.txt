# Copyright (c) 2011, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})

set(EXECUTABLE_OUTPUT_PATH  ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH     ${CMAKE_BINARY_DIR}/lib)


option(tests "Enable tests" ON)
option(bind  "Enable binding tests" ON)
option(arch  "Build for ia32, x64, or Arm" OFF)

if(arch STREQUAL x64)
    set(x64 1)
elseif(arch STREQUAL arm)
    include(Arm)
else()
    set(arch ia32)
    set(ia32 1)
endif()
message(STATUS "Building for architecture ${arch}")


project(dartruntime)

include(TargetClass)

if(V)
    set(CMAKE_VERBOSE_MAKEFILE ON)
    set(verbose ON)
else()
    message(STATUS)
    message(STATUS "Use option '-DV=1' to enable verbose build")
    message(STATUS)
endif()


if(APPLE)
    include(Apple)
elseif(UNIX)
    include(Linux)
elseif(WIN32)
    include(Windows)
endif()


if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE DEBUG)
endif()
if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
else()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_DEBUG} -DNDEBUG")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warn} ${multi} ${lang} ${link}")

if(verbose)
    message(STATUS "Used compiler flags: ${CMAKE_CXX_FLAGS}")
endif()


t_setTopDir(${CMAKE_SOURCE_DIR}/../runtime)

set(gen_dir ${CMAKE_CURRENT_BINARY_DIR}/gen)
file(MAKE_DIRECTORY ${gen_dir})


#
# common libraries
#

t_init(dart_api)
t_findHeaders(include .h)
t_addSources(vm/dart_api_impl.cc vm/debugger_api_impl.cc)
t_includeDirectories(.)
t_makeLibrary()


macro(embed_builtin_dart name)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc bin/builtin.h Builtin::${name}_source_)
endmacro()

t_init(dart_builtin)
t_init(dart_builtin)
t_findHeaders(bin .h)
t_findSources(bin .cc)
t_removeSources(ALL  main _test io_in builtin_in builtin_nolib snapshot)
t_removeForeignOsSources()
embed_builtin_dart(builtin bin/builtin.dart)
embed_builtin_dart(json ../lib/json/json.dart)
embed_builtin_dart(utf ../lib/utf/utf_vm.dart ../lib/utf/utf_core.dart ../lib/utf/utf8.dart ../lib/utf/utf16.dart ../lib/utf/utf32.dart)
embed_builtin_dart(uri  ../lib/uri/uri.dart)
t_findDartFiles(bin)
t_removeDartFiles(bin/builtin.dart)
t_prependDartFiles(bin/io.dart) # load first
embed_builtin_dart(io)
t_includeDirectories(.)
t_makeLibrary()


t_init(dart_lib)
t_findHeaders(lib .h)
t_findSources(lib .cc)
t_findSources(platform .h)
t_findSources(platform .cc)
t_removeForeignOsSources()
t_includeDirectories(.)
t_makeLibrary()


t_init(dart_vm)
t_findHeaders(vm .h)
t_findSources(vm .cc)
t_removeSources(ALL  _test _in.cc _api_impl bootstrap.cc bootstrap_nocorelib.cc)
t_removeForeignOsSources()
t_includeDirectories(.)
t_makeLibrary()


t_init(jscre)
t_findHeaders(third_party/jscre .h)
t_findSources(third_party/jscre .cpp)
t_removeSources(ALL ucptable)
t_addDefinitions(SUPPORT_UTF8 SUPPORT_UCP NO_RECURSE)
t_addCompileFlags(LINUX -Wno-conversion-null)
t_includeDirectories(.)
t_makeLibrary()


t_init(double_conversion)
t_findHeaders(third_party/double-conversion/src .h)
t_findSources(third_party/double-conversion/src .cc)
t_addCompileFlags(LINUX -Wno-conversion-null)
t_includeDirectories(.)
t_makeLibrary()



#
# without corelib
#

t_init(dart_plain)
# TODO using bin/main.cc without corelib makes no sense
t_addSources(bin/main.cc bin/builtin_nolib.cc bin/snapshot_empty.cc)
t_addSources(vm/bootstrap_nocorelib.cc)
t_includeDirectories(.)
t_makeExecutable()



#
# with corelib
#

macro(embed_boostrap_dart name)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc vm/bootstrap.h dart::Bootstrap::${name}_source_)
endmacro()

t_init(dart_corelib)
t_addSources(vm/bootstrap.cc)
t_findDartFiles(../corelib/src)
set(for_corelib_in lib/byte_array.dart lib/clock.dart lib/error.dart lib/literal_factory.dart lib/object.dart)
embed_boostrap_dart(corelib ${for_corelib_in})
t_findDartFiles(lib)
t_removeDartFiles(${for_corelib_in} lib/isolate.dart lib/mirrors_impl.dart)
t_findDartFiles(../corelib/src/implementation)
embed_boostrap_dart(corelib_impl)
embed_boostrap_dart(isolate ../lib/isolate/isolate_api.dart lib/isolate.dart)
embed_boostrap_dart(mirrors ../lib/mirrors/mirrors.dart lib/mirrors_impl.dart)
t_includeDirectories(.)
t_makeLibrary()


t_init(dart_no_snapshot)
t_addSources(bin/main.cc bin/builtin.cc bin/snapshot_empty.cc)
t_linkLibraries(dart_corelib)
t_includeDirectories(.)
t_makeExecutable()


t_init(gen_snapshot)
t_addSources(bin/gen_snapshot.cc bin/builtin.cc)
t_linkLibraries(dart_corelib)
t_includeDirectories(.)
t_makeExecutable()


t_init(dart)
t_addSources(bin/main.cc bin/builtin_nolib.cc)
t_addSnapshotFile(bin/snapshot_in.cc ${gen_dir}/snapshot_gen gen_snapshot)
t_linkLibraries(dart_corelib)
t_includeDirectories(.)
t_makeExecutable()


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
    t_linkLibraries(dart_corelib)
    t_makeTest()


    message(STATUS)
    get_filename_component(rep_root ${t_top}/.. ABSOLUTE)
    message(STATUS "Run tests from the source folder: '${rep_root}' !")
    message(STATUS)
endif()


if(bind)
    enable_testing()

    macro(p_addExecutables _dir)
        foreach(_it ${ARGN})
            t_init(${_dir}_${_it})
            t_addSources(${_dir}/${_dir}_${_it}.cc)
            t_linkLibraries(dart_corelib)
            t_includeDirectories(include)
            t_includeDirectories(.) # needed because dart_api.h isn't complete
            t_makeTest()
        endforeach()
    endmacro()

    p_addExecutables(bind NativeFunction_foo NativeFunction_userdata NativeFunction_nativefield NativeFunction_class)
endif()

