# Copyright (c) 2011, 2012 Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


if(dartruntime_dir)
    set(CMAKE_MODULE_PATH ${dartruntime_dir}/cmake)
else()
    get_filename_component(dartruntime_dir ${CMAKE_CURRENT_SOURCE_DIR}/.. ABSOLUTE)
endif()

include(TargetClass)
t_setTopDir(${dartruntime_dir}/runtime)
set(gen_dir ${CMAKE_CURRENT_BINARY_DIR}/gen)
file(MAKE_DIRECTORY ${gen_dir})

set(sdklib ../sdk/lib)


if(APPLE)
    include(Apple)
elseif(UNIX)
    include(Linux)
elseif(WIN32)
    include(Windows)
endif()


find_package(PythonInterp)


set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warn} ${multi} ${lang} ${link}")
if(verbose)
    message(STATUS "Used compiler flags: ${CMAKE_CXX_FLAGS}")
endif()


macro(t_embed_builtin_dart name postfix)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc bin/builtin.h Builtin::${name}${postfix})
endmacro()


macro(t_embed_boostrap_dart name postfix)
    t_addDartFiles(${ARGN})
    t_embedDartFiles(bin/builtin_in.cc ${gen_dir}/${name}.cc vm/bootstrap.h dart::Bootstrap::${name}${postfix})
endmacro()

macro(t_embed_builtin_dart_concat name postfix)
    t_concatLibrary(${gen_dir}/${name}.dart ${ARGN})
    t_setDartFiles(${gen_dir}/${name}.dart)
    t_embed_builtin_dart(${name} ${postfix})
endmacro()


# runtime/bin/utf_sources.gypi
set(crypto_sources_dart
    lib/crypto/crypto_vm.dart
    ${sdklib}/crypto/crypto_utils.dart
    ${sdklib}/crypto/hash_utils.dart
    ${sdklib}/crypto/hmac.dart
    ${sdklib}/crypto/md5.dart
    ${sdklib}/crypto/sha1.dart
    ${sdklib}/crypto/sha256.dart)

# runtime/bin/utf_sources.gypi
set(utf_sources_dart
    lib/utf/utf_vm.dart
    ${sdklib}/utf/utf_core.dart
    ${sdklib}/utf/utf8.dart
    ${sdklib}/utf/utf16.dart
    ${sdklib}/utf/utf32.dart)

# runtime/lib/lib_sources.gypi
set(lib_sources_dart
    lib/bool_patch.dart
    lib/date_patch.dart
    lib/array.dart
    lib/array_patch.dart
    lib/double.dart
    lib/double_patch.dart
    lib/error.dart
    lib/errors_patch.dart
    lib/expando_patch.dart
    lib/function_patch.dart
    lib/growable_array.dart
    lib/identical_patch.dart
    lib/immutable_map.dart
    lib/integers.dart
    lib/integers_patch.dart
    lib/invocation_mirror_patch.dart
    lib/map_patch.dart
    lib/object_patch.dart
    lib/print_patch.dart
    lib/regexp_patch.dart
    lib/stopwatch_patch.dart
    lib/string_base.dart
    lib/string_patch.dart
    lib/type_patch.dart
    lib/string_patch.dart
    lib/weak_property.dart)

# runtime/lib/lib_impl_sources.gypi
set(lib_impl_sources_dart
    lib/array_patch.dart
    lib/array_patch.dart
    lib/date_patch.dart
    lib/double.dart
    lib/expando_patch.dart
    lib/growable_array.dart
    lib/immutable_map.dart
    lib/integers.dart
    lib/math.dart
    lib/object_patch.dart
    lib/print_patch.dart
    lib/regexp_patch.dart
    lib/stopwatch_patch.dart
    lib/string_base.dart
    lib/string_patch.dart
    lib/weak_property.dart)


#
# common libraries
#

t_init(libdart_api)
t_findHeaders(include .h)
t_addHeaders(vm/version.h)
t_addSources(vm/dart_api_impl.cc vm/debugger_api_impl.cc)
t_includeDirectories(.)
t_makeLibrary()
t_installFiles(include/dart ../runtime/include/dart_api.h ../runtime/include/dart_debugger_api.h)


t_init(libdart_builtin)
t_findHeaders(bin .h)
t_findSources(bin .cc)
t_removeSources(ALL  main _test io_in builtin_in builtin_nolib snapshot)

t_removeForeignOsSources()
t_embed_builtin_dart(builtin _source_ bin/builtin.dart)
t_embed_builtin_dart(crypto _source_ ${crypto_sources_dart})
t_embed_builtin_dart(json _source_ ${sdklib}/json/json.dart)
t_embed_builtin_dart(utf _source_ ${utf_sources_dart})
#t_embed_builtin_dart(web ${sdklib}/web/web.dart)
t_embed_builtin_dart_concat(uri _source_ ${t_top}/${sdklib}/uri/uri.dart ${t_top}/${sdklib}/uri/helpers.dart ${t_top}/${sdklib}/uri/encode_decode.dart)
t_findDartFiles(${sdklib}/io)
t_embed_builtin_dart(io _source_)
t_findDartFiles(bin)
t_removeDartFiles(bin/builtin.dart)
t_removeSources(ALL secure_socket) # TODO nss dependency
t_removeDartFiles(bin/secure_socket.dart bin/secure_socket_patch.dart)
t_prependDartFiles(bin/io.dart) # load first
t_embed_builtin_dart(io_patch _)
t_includeDirectories(.)
t_makeLibrary()


t_init(libdart_vm)
t_findHeaders(vm .h)
t_findSources(vm .cc)
t_removeSources(ALL  _test _in.cc _api_impl bootstrap.cc bootstrap_nocorelib.cc vtune.cc)
t_removeForeignOsSources()
t_includeDirectories(.)
t_makeLibrary()


#
# third party libraries
#

t_init(libdart_jscre)
t_findHeaders(third_party/jscre .h)
t_findSources(third_party/jscre .cpp)
t_removeSources(ALL ucptable)
t_addDefinitions(SUPPORT_UTF8 SUPPORT_UCP NO_RECURSE)
t_addCompileFlags(LINUX -Wno-conversion-null)
t_includeDirectories(.)
t_makeLibrary()


t_init(libdart_double_conversion)
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
t_findDartFiles(${sdklib}/core)
t_removeDartFiles(${sdklib}/core/core.dart)
t_embed_boostrap_dart(corelib _source_)
t_embed_boostrap_dart(corelib_patch _ ${lib_sources_dart})
t_embed_boostrap_dart(isolate _source_ ${sdklib}/isolate/base.dart ${sdklib}/isolate/timer.dart)
t_embed_boostrap_dart(isolate_patch _ lib/isolate_patch.dart)
t_embed_boostrap_dart(math _source_ ${sdklib}/math/base.dart ${sdklib}/math/random.dart)
t_embed_boostrap_dart(math_patch _ lib/math_patch.dart)
t_embed_boostrap_dart(mirrors _source_ lib/empty_source.dart)
t_embed_boostrap_dart(mirrors_patch _ ${sdklib}/mirrors/mirrors.dart lib/mirrors_impl.dart)
t_embed_boostrap_dart(scalarlist _source_ ${sdklib}/scalarlist/scalarlist.dart ${sdklib}/scalarlist/byte_arrays.dart)
t_embed_boostrap_dart(scalarlist_patch _ lib/byte_array.dart)
t_embed_boostrap_dart(collection _source_
    ${sdklib}/collection/arrays.dart
    ${sdklib}/collection/collections.dart
    ${sdklib}/collection/maps.dart
    ${sdklib}/collection/splay_tree.dart)
t_includeDirectories(.)
t_makeLibrary()


set(libdart_withcore
    libdart_api
    libdart_vm
    libdart_lib_withcore
    libdart_lib
    libdart_builtin
    libdart_jscre
    libdart_double_conversion
    )

