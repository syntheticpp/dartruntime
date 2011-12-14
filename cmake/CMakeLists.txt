# Copyright (c) 2011, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})

set(EXECUTABLE_OUTPUT_PATH  ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH     ${CMAKE_BINARY_DIR}/lib)


project(dartruntime)

include(TargetClass)


if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE DEBUG)
endif()
if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
else()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_DEBUG} -DNDEBUG")
endif()

if(UNIX AND NOT APPLE)
    set(LINUX 1)
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
    message(STATUS "Using GCC version ${GCC_VERSION}")
    set(warn  "-Wall -Wextra -Wno-unused-parameter -Wnon-virtual-dtor")
    set(lang  "-ansi -fno-rtti -fno-exceptions")
    set(link  "-fvisibility=hidden -fvisibility-inlines-hidden")
    if(GCC_VERSION VERSION_LESS 4.6 AND NOT APPLE)
        set(warn "${warn} -Werror")
    endif()
    if(NOT GCC_VERSION VERSION_LESS 4.3)
        set(warn "${warn} -Wno-conversion-null -Wvla")
    endif()
    if(LINUX)
        set(librt -lrt)
        set(multi "-m32 -MMD -fPIC ")
    endif()
    if(APPLE)
        set(multi "-arch i386")
        set(bin_sub_dir \${CONFIGURATION})
    endif()
    
endif()

if(MSVC)
    if(NOT PYTHONINTERP_FOUND OR NOT openssl)
        include(WindowsDependencies)
    endif()
    if(NOT openssl)
        message(FATAL_ERROR "'openssl' not set, install 'Win32OpenSSL' and set openssl")
    endif()
    include_directories(${openssl}/include)
    set(_ldir ${openssl}/lib/VC)
    set(libopenssl debug ${_ldir}/libeay32MDd.lib optimized ${_ldir}/libeay32MD.lib)
    if(MSVC_IDE)
        set(bin_sub_dir "\$(Configuration)")
    endif()
    set(warn_level 1)
    if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
        string(REGEX REPLACE "/W[0-4]" "/W${warn_level}" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    endif()
    if(CMAKE_CXX_FLAGS MATCHES "/EHsc")
        string(REGEX REPLACE "/Esc" "/Esc-" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    endif()
    #set(warn_error   "/we4101")
    set(warn_disable "/wd4018 /wd4099 /wd4100 /wd4127 /wd4146 /wd4189 /wd4200 /wd4244 /wd4245 /wd4291 /wd4389 /wd4512 /wd4611 /wd4701 /wd4702 /wd4731 /wd4706 /wd4800")
    set(warn "${warn_disable} ${warn_error}")
    set(lang  "/GR- /GS /Zc:wchar_t")
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
    # disable checked iterators for msvc release builds to get maximum speed
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /D_SECURE_SCL=0")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warn} ${multi} ${lang} ${link}")


t_setTopDir(${CMAKE_SOURCE_DIR}/../runtime)


#
# common libraries
#

t_includeDirectories(.)

t_init(dart_api)
t_findHeaders(include .h)
t_addSources(vm/dart_api_impl.cc vm/debugger_api_impl.cc)
t_makeLibrary()


t_init(dart_builtin)
t_findHeaders(bin .h)
t_findSources(bin .cc)
t_removeSources(ALL  main _test builtin_in builtin_nolib snapshot)
t_removeSources(LINUX _win _macos)
t_removeSources(APPLE _win _linux)
t_removeSources(WIN32 _macos _linux _posix)
t_findDartFiles(bin)
t_prependDartFiles(bin/builtin.dart) # load first
t_embedDartFiles(bin/builtin_in.cc)
t_makeLibrary()


t_init(dart_lib)
t_findHeaders(lib .h)
t_findSources(lib .cc)
t_makeLibrary()


t_init(dart_vm)
t_findHeaders(vm .h)
t_findSources(vm .cc)
t_removeSources(ALL  _test _in.cc _api_impl bootstrap.cc bootstrap_nocorelib.cc)
t_removeSources(LINUX _win _macos)
t_removeSources(APPLE _win _linux)
t_removeSources(WIN32 _macos _linux _posix)
t_makeLibrary()


t_init(jscre)
add_definitions(-DSUPPORT_UTF8 -DSUPPORT_UCP)
t_findHeaders(third_party/jscre .h)
t_findSources(third_party/jscre .cpp)
t_removeSources(ALL ucptable)
t_makeLibrary()


t_init(double_conversion)
t_findHeaders(third_party/double-conversion/src .h)
t_findSources(third_party/double-conversion/src .cc)
t_makeLibrary()



#
# without corelib
#

t_init(dart_plain)
# TODO using bin/main.cc without corelib makes no sense 
t_addSources(bin/main.cc bin/builtin_nolib.cc bin/snapshot_empty.cc)
t_addSources(vm/bootstrap_nocorelib.cc)
t_linkLibraries()
t_makeExecutable()



#
# with corelib
#    

t_init(dart_corelib)
t_addSources(vm/bootstrap.cc)
t_findDartFiles(../corelib/src)
set(for_corelib_in lib/byte_buffer.dart lib/clock.dart lib/error.dart lib/literal_factory.dart lib/object.dart)
t_addDartFiles(${for_corelib_in})
t_embedDartFiles(vm/corelib_in.cc)
t_findDartFiles(lib)
t_removeDartFiles(${for_corelib_in})
t_findDartFiles(../corelib/src/implementation)
t_embedDartFiles(vm/corelib_impl_in.cc)
t_makeLibrary()
  

t_init(dart_no_snapshot)
t_addSources(bin/main.cc bin/builtin.cc bin/snapshot_empty.cc)
t_linkLibraries(dart_corelib)
t_makeExecutable()


t_init(gen_snapshot)
t_addSources(bin/gen_snapshot.cc bin/builtin.cc)
t_linkLibraries(dart_corelib)
t_makeExecutable()

        
t_init(dart)
t_addSources(bin/main.cc bin/builtin_nolib.cc)
t_addSnapshotFile(bin/snapshot_in.cc gen_snapshot)
t_linkLibraries(dart_corelib)
t_makeExecutable()

