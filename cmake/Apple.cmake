# Copyright (c) 2012, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


include(Gcc)

set(bin_sub_dir \${CONFIGURATION})
message(STATUS "Using SDK in '${CMAKE_OSX_SYSROOT}'")

if(ia32)
    set(arch i386)
elseif(x64)
    set(arch x86_64)
endif()

set(multi "-arch ${arch} -isysroot ${CMAKE_OSX_SYSROOT}")

set(warn "${warn} -Wno-trigraphs -fmessage-length=0 -Wno-deprecated-declarations")

set(libopenssl -lpthread -lcrypto)

# Clang?
