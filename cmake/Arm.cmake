# Copyright (c) 2012, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set(arm 1)

message(STATUS)
message(STATUS "Android toolchain, totally broken and experimental!")
message(STATUS "   * unpack NDK: http://developer.android.com/sdk/ndk/index.html")
message(STATUS "   * in NDK dir call ./build/tools/make-standalone-toolchain.sh")
message(STATUS "   * unpack the generated tar and pass it to cmake: -Dtoolchain=")

if(NOT toolchain)
    message(FATAL_ERROR "'toolchain' not set. cross-compiler needed."
                        "e.g.: cmake -Dtoolchain=/opt/arm-linux-androideabi-4.4.3/bin/arm-linux-androideabi-")
endif()

# http://www.vtk.org/Wiki/CMake_Cross_Compiling
set(CMAKE_CROSSCOMPILING TRUE)
set(arm_compiler_path_base ${toolchain})
set(CMAKE_C_COMPILER ${arm_compiler_path_base}gcc)
set(CMAKE_CXX_COMPILER ${arm_compiler_path_base}g++)

add_definitions(-D__STDC_INT64__)

message(STATUS "OpenSsl for Android")
message(STATUS "   * clone  git://github.com/guardianproject/openssl-android.git")
message(STATUS "   * build with NDK: - chmod u+x path-to-NDK/ndk-build")
message(STATUS "                     - path-to-NDK/ndk-build")
message(STATUS "   * pass openssl directory path to cmake: -Dopenssl=...")
if(NOT openssl)
    message(FATAL_ERROR "'openssl' not set, it should point to a directory")
endif()
include_directories(${openssl}/include)
set(openssl_link_flag "-L${openssl}")

message(STATUS)

