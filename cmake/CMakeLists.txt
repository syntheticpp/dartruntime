# Copyright (c) 2011, 2012 Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})

set(EXECUTABLE_OUTPUT_PATH  ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH     ${CMAKE_BINARY_DIR}/lib)

option(tests   "Enable tests" ON)
option(bind    "Enable binding tests" ON)
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

include(TargetClass)
t_setTopDir(${CMAKE_SOURCE_DIR}/../runtime)
set(gen_dir ${CMAKE_CURRENT_BINARY_DIR}/gen)
file(MAKE_DIRECTORY ${gen_dir})


if(V)
    set(CMAKE_VERBOSE_MAKEFILE ON)
    set(verbose ON)
else()
    message(STATUS)
    message(STATUS "Use option '-DV=1' to enable verbose build")
endif()


if(APPLE)
    include(Apple)
elseif(UNIX)
    include(Linux)
elseif(WIN32)
    include(Windows)
endif()


if(release)
    set(CMAKE_BUILD_TYPE Release)
endif()
if(verbose)
    message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warn} ${multi} ${lang} ${link}")
if(verbose)
    message(STATUS "Used compiler flags: ${CMAKE_CXX_FLAGS}")
endif()



macro(t_embed_builtin_dart name)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc bin/builtin.h Builtin::${name}_source_)
endmacro()

macro(t_embed_boostrap_dart name postfix)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc vm/bootstrap.h dart::Bootstrap::${name}${postfix})
endmacro()

macro(t_embed_builtin_dart_concat name)
    t_concatLibrary(${gen_dir}/${name}.dart ${ARGN})
    t_setDartFiles(${gen_dir}/${name}.dart)
    t_embed_builtin_dart(${name})
endmacro()

set(crypto_sources_dart
    ../lib/crypto/crypto_vm.dart
    ../lib/crypto/crypto_utils.dart
    ../lib/crypto/hash_utils.dart
    ../lib/crypto/hmac.dart
    ../lib/crypto/md5.dart
    ../lib/crypto/sha1.dart
    ../lib/crypto/sha256.dart)

set(utf_sources_dart
    ../lib/utf/utf_vm.dart
    ../lib/utf/utf_core.dart
    ../lib/utf/utf8.dart
    ../lib/utf/utf16.dart
    ../lib/utf/utf32.dart)

set(lib_sources_dart
    lib/byte_array.dart
    lib/error.dart
    lib/expando_impl.dart
    lib/literal_factory.dart
    lib/object.dart
    lib/weak_property.dart)

set(lib_impl_sources_dart
    lib/array.dart
    lib/bool.dart
    lib/date_patch.dart
    lib/double.dart
    lib/growable_array.dart
    lib/immutable_map.dart
    lib/integers.dart
    lib/math.dart
    lib/regexp_patch.dart
    lib/stopwatch_patch.dart
    lib/string.dart)


#
# common libraries
#

t_init(libdart_api)
t_findHeaders(include .h)
t_addSources(vm/dart_api_impl.cc vm/debugger_api_impl.cc)
t_includeDirectories(.)
t_makeLibrary()
t_installFiles(include/dart ../runtime/include/dart_api.h ../runtime/include/dart_debugger_api.h)

t_init(libdart_builtin)
t_findHeaders(bin .h)
t_findSources(bin .cc)
t_removeSources(ALL  main _test io_in builtin_in builtin_nolib snapshot)
t_removeForeignOsSources()
t_embed_builtin_dart(builtin bin/builtin.dart)
t_embed_builtin_dart(crypto ${crypto_sources_dart})
t_embed_builtin_dart(json ../lib/json/json.dart)
t_embed_builtin_dart(utf ${utf_sources_dart})
t_embed_builtin_dart(web ../lib/web/web.dart)
t_embed_builtin_dart_concat(uri ${t_top}/../lib/uri/uri.dart ${t_top}/../lib/uri/helpers.dart ${t_top}/../lib/uri/encode_decode.dart)
t_findDartFiles(bin)
t_removeDartFiles(bin/builtin.dart)
t_prependDartFiles(bin/io.dart) # load first
t_embed_builtin_dart(io)
t_includeDirectories(.)
t_makeLibrary()

t_init(libdart_vm)
t_findHeaders(vm .h)
t_findSources(vm .cc)
t_removeSources(ALL  _test _in.cc _api_impl bootstrap.cc bootstrap_nocorelib.cc)
t_removeForeignOsSources()
t_includeDirectories(.)
t_makeLibrary()


#
# third party libraries
#

t_init(libjscre)
t_findHeaders(third_party/jscre .h)
t_findSources(third_party/jscre .cpp)
t_removeSources(ALL ucptable)
t_addDefinitions(SUPPORT_UTF8 SUPPORT_UCP NO_RECURSE)
t_addCompileFlags(LINUX -Wno-conversion-null)
t_includeDirectories(.)
t_makeLibrary()


t_init(libdouble_conversion)
t_findHeaders(third_party/double-conversion/src .h)
t_findSources(third_party/double-conversion/src .cc)
t_addCompileFlags(LINUX -Wno-conversion-null)
t_includeDirectories(.)
t_makeLibrary()


#
# libdart_lib with or without corelib
#

t_init(libdart_lib)
t_findHeaders(lib .h)
t_findSources(lib .cc)
t_findSources(platform .h)
t_findSources(platform .cc)
t_removeForeignOsSources()
t_includeDirectories(.)
t_makeLibrary()


t_init(libdart_lib_withcore)
t_addSources(vm/bootstrap.cc)
t_findDartFiles(../corelib/src)
t_embed_boostrap_dart(corelib _source_)
t_embed_boostrap_dart(corelib_patch _ ${lib_sources_dart})
t_findDartFiles(../corelib/src/implementation)
t_embed_boostrap_dart(corelib_impl _source_)
t_embed_boostrap_dart(corelib_impl_patch _ ${lib_impl_sources_dart})
t_embed_boostrap_dart(isolate _source_ ../lib/isolate/base.dart ../lib/isolate/timer.dart)
t_embed_boostrap_dart(isolate_patch _ lib/isolate_patch.dart)
t_embed_boostrap_dart(math _source_ ../lib/math/base.dart ../lib/math/random.dart)
t_embed_boostrap_dart(math_patch _ lib/math_patch.dart)
t_embed_boostrap_dart(mirrors _source_ lib/empty_source.dart)
t_embed_boostrap_dart(mirrors_patch _ ../lib/mirrors/mirrors.dart lib/mirrors_impl.dart)
t_includeDirectories(.)
t_makeLibrary()


set(libdart_withcore
    libdart_api
    libdart_builtin
    libdart_lib_withcore
    libdart_lib
    libdart_vm
    libjscre
    libdouble_conversion
    )


#
# snapshot tool
#

t_init(gen_snapshot)
t_addSources(bin/gen_snapshot.cc bin/builtin.cc)
t_linkLibraries(${libdart_withcore})
t_includeDirectories(.)
t_makeExecutable()


#
# dart executables
#

t_init(dart_plain)
# TODO using bin/main.cc without corelib makes no sense
t_addSources(bin/main.cc bin/builtin_nolib.cc bin/snapshot_empty.cc)
t_addSources(vm/bootstrap_nocorelib.cc)
t_linkLibraries(
    libdart_lib
    libdart_vm
    libjscre
    libdouble_conversion)
t_includeDirectories(.)
t_makeExecutable()

t_init(dart_no_snapshot)
t_addSources(bin/main.cc bin/builtin.cc bin/snapshot_empty.cc)
t_linkLibraries(libdart_lib_withcore)
t_includeDirectories(.)
t_makeExecutable()


t_init(dart)
t_addSources(bin/main.cc bin/builtin_nolib.cc)
t_embed_builtin_dart(web ../lib/web/web.dart)
t_addSnapshotFile(bin/snapshot_in.cc ${gen_dir}/snapshot_gen gen_snapshot)
t_linkLibraries(${libdart_withcore})
t_includeDirectories(.)
t_makeExecutable()
t_install()




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



if(bind)
    enable_testing()

    macro(p_addExecutables _dir _prefix)
        foreach(_it ${ARGN})
            t_init(${_prefix}${_it})
            t_addSources(${_dir}/${_prefix}${_it}.cc)
            t_linkLibraries(${libdart_withcore})
            t_includeDirectories(include)
            t_includeDirectories(.) # needed because dart_api.h isn't complete
            t_makeTest()
        endforeach()
    endmacro()

    p_addExecutables(bind bind_ NativeFunction_foo NativeFunction_userdata NativeFunction_nativefield NativeFunction_class)
    p_addExecutables(examples "" minimal_http_server)
endif()

